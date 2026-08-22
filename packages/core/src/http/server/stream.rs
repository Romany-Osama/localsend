use crate::http::server::common::collect_to_json::CollectToJson;
use crate::http::server::common::error::AppError;
use crate::http::server::common::query::parse_query;
use crate::http::server::common::response::{BoxedBody, JsonResponse};
use crate::http::server::{AppState, RequestClientInfo};
use bytes::Bytes;
use http_body_util::{BodyExt, StreamBody};
use hyper::body::{Frame, Incoming};
use hyper::{http, Request, Response, StatusCode};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::path::{Component, Path, PathBuf};
use std::sync::Arc;
use std::time::{Duration, Instant};
use tokio::io::{AsyncReadExt, AsyncSeekExt, SeekFrom};
use tokio::sync::{mpsc, oneshot, Mutex};
use tokio_stream::wrappers::ReceiverStream;
use tokio_stream::StreamExt;
use uuid::Uuid;

const GRANT_TTL: Duration = Duration::from_secs(30 * 60);
const STREAM_BUFFER_SIZE: usize = 512 * 1024;

/// A user-selected root that can be browsed and streamed read-only.
pub struct StreamRoot {
    pub id: String,
    pub name: String,
    pub path: PathBuf,
}

/// Configuration for the optional Stream & Browse API.
pub struct StreamConfig {
    pub roots: Vec<StreamRoot>,
    pub event_tx: mpsc::Sender<StreamEvent>,
}

/// Events emitted to the application before a remote client can browse or read.
#[derive(Debug)]
pub enum StreamEvent {
    PrepareSession {
        ip: super::PeerIp,
        session_id: String,
        user_agent: Option<String>,
        decision_tx: oneshot::Sender<bool>,
    },
    FileRequest {
        ip: super::PeerIp,
        session_id: String,
        request_id: String,
        entry: StreamEntry,
        purpose: String,
        decision_tx: oneshot::Sender<bool>,
    },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct StreamEntry {
    pub root_id: String,
    pub path: String,
    pub name: String,
    pub kind: String,
    pub size: u64,
    pub modified_at: Option<String>,
    pub mime_type: String,
    pub streamable: bool,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct StreamRootInfo {
    pub id: String,
    pub name: String,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct StreamSessionResponse {
    pub session_id: String,
    pub mode: &'static str,
    pub expires_in_seconds: u64,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct StreamFileGrantResponse {
    pub request_id: String,
    pub grant_id: String,
    pub file: StreamEntry,
    pub expires_in_seconds: u64,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct SessionRequest {
    #[serde(default)]
    user_agent: Option<String>,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct FileRequest {
    session_id: String,
    root_id: String,
    path: String,
    #[serde(default = "default_purpose")]
    purpose: String,
}

fn default_purpose() -> String {
    "open".to_string()
}

pub(crate) struct StreamState {
    roots: Vec<StreamRoot>,
    event_tx: mpsc::Sender<StreamEvent>,
    sessions: Mutex<HashMap<String, StreamSession>>,
    grants: Mutex<HashMap<String, StreamGrant>>,
}

struct StreamSession {
    ip: super::PeerIp,
    accepted: bool,
    expires_at: Instant,
}

struct StreamGrant {
    session_id: String,
    ip: super::PeerIp,
    path: PathBuf,
    file: StreamEntry,
    expires_at: Instant,
}

impl StreamState {
    pub(crate) fn new(config: StreamConfig) -> Self {
        Self {
            roots: config.roots,
            event_tx: config.event_tx,
            sessions: Mutex::new(HashMap::new()),
            grants: Mutex::new(HashMap::new()),
        }
    }
}

pub(crate) async fn prepare_session(
    req: Request<Incoming>,
    state: AppState,
    client_info: RequestClientInfo,
) -> Result<Response<BoxedBody>, AppError> {
    let stream = require_stream(&state)?;
    let payload = req.into_body().collect_to_json::<SessionRequest>().await?;
    let session_id = Uuid::new_v4().to_string();

    {
        let mut sessions = stream.sessions.lock().await;
        sessions.insert(
            session_id.clone(),
            StreamSession {
                ip: client_info.ip,
                accepted: false,
                expires_at: Instant::now() + GRANT_TTL,
            },
        );
    }

    let (decision_tx, decision_rx) = oneshot::channel();
    stream
        .event_tx
        .send(StreamEvent::PrepareSession {
            ip: client_info.ip,
            session_id: session_id.clone(),
            user_agent: payload.user_agent,
            decision_tx,
        })
        .await
        .map_err(|_| AppError::Status(StatusCode::INTERNAL_SERVER_ERROR))?;

    let accepted = match tokio::time::timeout(GRANT_TTL, decision_rx).await {
        Ok(result) => result.map_err(|_| AppError::Status(StatusCode::INTERNAL_SERVER_ERROR))?,
        Err(_) => {
            stream.sessions.lock().await.remove(&session_id);
            return Err(AppError::Message(
                StatusCode::REQUEST_TIMEOUT,
                "Stream session approval timed out".to_string(),
            ));
        }
    };
    if !accepted {
        stream.sessions.lock().await.remove(&session_id);
        return Err(AppError::Message(
            StatusCode::FORBIDDEN,
            "Stream session rejected".to_string(),
        ));
    }

    let session_accepted = {
        let mut sessions = stream.sessions.lock().await;
        let expired = sessions
            .get(&session_id)
            .map(|session| session.expires_at <= Instant::now())
            .unwrap_or(true);
        if expired {
            sessions.remove(&session_id);
            false
        } else if let Some(session) = sessions.get_mut(&session_id) {
            session.accepted = true;
            session.expires_at = Instant::now() + GRANT_TTL;
            true
        } else {
            false
        }
    };
    if !session_accepted {
        return Err(AppError::Message(
            StatusCode::REQUEST_TIMEOUT,
            "Stream session approval timed out".to_string(),
        ));
    }

    Ok(JsonResponse {
        status: StatusCode::OK,
        body: StreamSessionResponse {
            session_id,
            mode: "read-only",
            expires_in_seconds: GRANT_TTL.as_secs(),
        },
    }
    .into_response())
}

pub(crate) async fn roots(
    req: Request<Incoming>,
    state: AppState,
    client_info: RequestClientInfo,
) -> Result<Response<BoxedBody>, AppError> {
    let stream = require_stream(&state)?;
    let session_id = required_query(req.uri().query(), "sessionId")?;
    validate_session(&stream, &session_id, &client_info).await?;

    let body: Vec<StreamRootInfo> = stream
        .roots
        .iter()
        .map(|root| StreamRootInfo {
            id: root.id.clone(),
            name: root.name.clone(),
        })
        .collect();
    Ok(JsonResponse {
        status: StatusCode::OK,
        body,
    }
    .into_response())
}

pub(crate) async fn entries(
    req: Request<Incoming>,
    state: AppState,
    client_info: RequestClientInfo,
) -> Result<Response<BoxedBody>, AppError> {
    let stream = require_stream(&state)?;
    let query = parse_query(req.uri().query());
    let session_id = query
        .get("sessionId")
        .cloned()
        .ok_or_else(|| AppError::BadRequest("Missing sessionId".to_string()))?;
    validate_session(&stream, &session_id, &client_info).await?;
    let root_id = query
        .get("rootId")
        .cloned()
        .ok_or_else(|| AppError::BadRequest("Missing rootId".to_string()))?;
    let relative = query.get("path").cloned().unwrap_or_default();
    let (root, directory) = resolve_path(&stream, &root_id, &relative, true)?;

    let mut output = Vec::new();
    for item in
        std::fs::read_dir(&directory).map_err(|_| AppError::Status(StatusCode::NOT_FOUND))?
    {
        let item = item.map_err(|_| AppError::Status(StatusCode::INTERNAL_SERVER_ERROR))?;
        let file_type = item
            .file_type()
            .map_err(|_| AppError::Status(StatusCode::INTERNAL_SERVER_ERROR))?;
        // Do not follow symlinks in the browsing API.
        if file_type.is_symlink() {
            continue;
        }
        let metadata = item
            .metadata()
            .map_err(|_| AppError::Status(StatusCode::INTERNAL_SERVER_ERROR))?;
        let name = item.file_name().to_string_lossy().to_string();
        let child_relative = join_relative(&relative, &name);
        let is_dir = file_type.is_dir();
        let mime_type = if is_dir {
            "inode/directory".to_string()
        } else {
            mime_for_name(&name)
        };
        let modified_at = crate::model::transfer::FileMetadata::from_fs_metadata(&metadata)
            .and_then(|metadata| metadata.modified);
        output.push(StreamEntry {
            root_id: root.id.clone(),
            path: child_relative,
            name,
            kind: if is_dir { "directory" } else { "file" }.to_string(),
            size: if is_dir { 0 } else { metadata.len() },
            modified_at,
            mime_type: mime_type.clone(),
            streamable: !is_dir && is_streamable_mime(&mime_type),
        });
    }
    output.sort_by_key(|entry| (entry.kind != "directory", entry.name.to_ascii_lowercase()));

    Ok(JsonResponse {
        status: StatusCode::OK,
        body: output,
    }
    .into_response())
}

pub(crate) async fn file_request(
    req: Request<Incoming>,
    state: AppState,
    client_info: RequestClientInfo,
) -> Result<Response<BoxedBody>, AppError> {
    let stream = require_stream(&state)?;
    let payload = req.into_body().collect_to_json::<FileRequest>().await?;
    validate_session(&stream, &payload.session_id, &client_info).await?;
    let (root, path) = resolve_path(&stream, &payload.root_id, &payload.path, false)?;
    let metadata = std::fs::metadata(&path).map_err(|_| AppError::Status(StatusCode::NOT_FOUND))?;
    if !metadata.is_file() {
        return Err(AppError::BadRequest(
            "The selected entry is not a file".to_string(),
        ));
    }

    let file_name = path
        .file_name()
        .map(|name| name.to_string_lossy().to_string())
        .unwrap_or_else(|| "file".to_string());
    let mime_type = mime_for_name(&file_name);
    let entry = StreamEntry {
        root_id: root.id.clone(),
        path: payload.path,
        name: file_name,
        kind: "file".to_string(),
        size: metadata.len(),
        modified_at: crate::model::transfer::FileMetadata::from_fs_metadata(&metadata)
            .and_then(|metadata| metadata.modified),
        streamable: is_streamable_mime(&mime_type),
        mime_type,
    };
    let request_id = Uuid::new_v4().to_string();
    let (decision_tx, decision_rx) = oneshot::channel();
    stream
        .event_tx
        .send(StreamEvent::FileRequest {
            ip: client_info.ip,
            session_id: payload.session_id.clone(),
            request_id: request_id.clone(),
            entry: entry.clone(),
            purpose: payload.purpose,
            decision_tx,
        })
        .await
        .map_err(|_| AppError::Status(StatusCode::INTERNAL_SERVER_ERROR))?;

    let accepted = match tokio::time::timeout(GRANT_TTL, decision_rx).await {
        Ok(result) => result.map_err(|_| AppError::Status(StatusCode::INTERNAL_SERVER_ERROR))?,
        Err(_) => {
            return Err(AppError::Message(
                StatusCode::REQUEST_TIMEOUT,
                "Stream file approval timed out".to_string(),
            ));
        }
    };
    if !accepted {
        return Err(AppError::Message(
            StatusCode::FORBIDDEN,
            "File request rejected".to_string(),
        ));
    }

    let grant_id = Uuid::new_v4().to_string();
    stream.grants.lock().await.insert(
        grant_id.clone(),
        StreamGrant {
            session_id: payload.session_id,
            ip: client_info.ip,
            path,
            file: entry.clone(),
            expires_at: Instant::now() + GRANT_TTL,
        },
    );

    Ok(JsonResponse {
        status: StatusCode::OK,
        body: StreamFileGrantResponse {
            request_id,
            grant_id,
            file: entry,
            expires_in_seconds: GRANT_TTL.as_secs(),
        },
    }
    .into_response())
}

pub(crate) async fn stream_file(
    req: Request<Incoming>,
    state: AppState,
    client_info: RequestClientInfo,
) -> Result<Response<BoxedBody>, AppError> {
    let stream = require_stream(&state)?;
    let grant_id = required_query(req.uri().query(), "grantId")?;
    let grant = {
        let mut grants = stream.grants.lock().await;
        let Some(grant) = grants.get(&grant_id) else {
            return Err(AppError::Status(StatusCode::FORBIDDEN));
        };
        if grant.expires_at <= Instant::now() || grant.ip != client_info.ip {
            grants.remove(&grant_id);
            return Err(AppError::Status(StatusCode::FORBIDDEN));
        }
        let session_valid = stream
            .sessions
            .lock()
            .await
            .get(&grant.session_id)
            .is_some_and(|session| {
                session.accepted
                    && session.ip == client_info.ip
                    && session.expires_at > Instant::now()
            });
        if !session_valid {
            grants.remove(&grant_id);
            return Err(AppError::Status(StatusCode::FORBIDDEN));
        }
        StreamGrant {
            session_id: grant.session_id.clone(),
            ip: grant.ip,
            path: grant.path.clone(),
            file: grant.file.clone(),
            expires_at: grant.expires_at,
        }
    };

    let (start, end, partial) =
        parse_range(req.headers().get(http::header::RANGE), grant.file.size)?;
    let content_length = if grant.file.size == 0 {
        0
    } else {
        end - start + 1
    };
    let (tx, rx) = mpsc::channel::<Bytes>(8);
    let path = grant.path.clone();
    tokio::spawn(async move {
        let result = async {
            let mut file = tokio::fs::File::open(path).await?;
            file.seek(SeekFrom::Start(start)).await?;
            let mut remaining = content_length;
            let mut buffer = vec![0_u8; STREAM_BUFFER_SIZE];
            while remaining > 0 {
                let wanted = remaining.min(buffer.len() as u64) as usize;
                let read = file.read(&mut buffer[..wanted]).await?;
                if read == 0 {
                    break;
                }
                remaining -= read as u64;
                if tx
                    .send(Bytes::copy_from_slice(&buffer[..read]))
                    .await
                    .is_err()
                {
                    break;
                }
            }
            Ok::<(), std::io::Error>(())
        }
        .await;
        if let Err(error) = result {
            tracing::warn!("Stream read failed: {error}");
        }
    });

    let body = StreamBody::new(
        ReceiverStream::new(rx).map(|chunk| Ok::<_, std::io::Error>(Frame::data(chunk))),
    )
    .boxed();
    let mut response = Response::new(body);
    *response.status_mut() = if partial {
        StatusCode::PARTIAL_CONTENT
    } else {
        StatusCode::OK
    };
    let headers = response.headers_mut();
    headers.insert(
        http::header::CONTENT_TYPE,
        http::HeaderValue::from_str(&grant.file.mime_type)
            .unwrap_or_else(|_| http::HeaderValue::from_static("application/octet-stream")),
    );
    headers.insert(
        http::header::ACCEPT_RANGES,
        http::HeaderValue::from_static("bytes"),
    );
    headers.insert(
        http::header::CONTENT_LENGTH,
        http::HeaderValue::from(content_length),
    );
    if partial {
        let value = format!("bytes {start}-{end}/{}", grant.file.size);
        headers.insert(
            http::header::CONTENT_RANGE,
            http::HeaderValue::from_str(&value)
                .map_err(|_| AppError::Status(StatusCode::INTERNAL_SERVER_ERROR))?,
        );
    }
    Ok(response)
}

pub(crate) async fn revoke_session(
    req: Request<Incoming>,
    state: AppState,
    client_info: RequestClientInfo,
) -> Result<Response<BoxedBody>, AppError> {
    let stream = require_stream(&state)?;
    let session_id = required_query(req.uri().query(), "sessionId")?;
    validate_session(&stream, &session_id, &client_info).await?;
    stream.sessions.lock().await.remove(&session_id);
    stream
        .grants
        .lock()
        .await
        .retain(|_, grant| grant.session_id != session_id);
    Ok(Response::new(
        crate::http::server::common::response::empty_body(),
    ))
}

fn require_stream(state: &AppState) -> Result<Arc<StreamState>, AppError> {
    state
        .stream
        .clone()
        .ok_or(AppError::Status(StatusCode::NOT_FOUND))
}

async fn validate_session(
    state: &StreamState,
    session_id: &str,
    client_info: &RequestClientInfo,
) -> Result<(), AppError> {
    let mut sessions = state.sessions.lock().await;
    let valid = sessions.get(session_id).is_some_and(|session| {
        session.accepted && session.ip == client_info.ip && session.expires_at > Instant::now()
    });
    if valid {
        Ok(())
    } else {
        sessions.remove(session_id);
        Err(AppError::Status(StatusCode::FORBIDDEN))
    }
}

fn required_query(query: Option<&str>, key: &str) -> Result<String, AppError> {
    parse_query(query)
        .get(key)
        .cloned()
        .ok_or_else(|| AppError::BadRequest(format!("Missing {key}")))
}

fn resolve_path<'a>(
    state: &'a StreamState,
    root_id: &str,
    relative: &str,
    directory_required: bool,
) -> Result<(&'a StreamRoot, PathBuf), AppError> {
    let root = state
        .roots
        .iter()
        .find(|root| root.id == root_id)
        .ok_or(AppError::Status(StatusCode::NOT_FOUND))?;
    let relative_path = normalize_relative(relative)?;
    let canonical_root =
        std::fs::canonicalize(&root.path).map_err(|_| AppError::Status(StatusCode::NOT_FOUND))?;
    let candidate = std::fs::canonicalize(root.path.join(relative_path))
        .map_err(|_| AppError::Status(StatusCode::NOT_FOUND))?;
    if !candidate.starts_with(&canonical_root) {
        return Err(AppError::Status(StatusCode::FORBIDDEN));
    }
    let metadata =
        std::fs::metadata(&candidate).map_err(|_| AppError::Status(StatusCode::NOT_FOUND))?;
    if directory_required && !metadata.is_dir() {
        return Err(AppError::BadRequest(
            "The selected entry is not a directory".to_string(),
        ));
    }
    Ok((root, candidate))
}

fn normalize_relative(value: &str) -> Result<PathBuf, AppError> {
    let mut output = PathBuf::new();
    for component in Path::new(value).components() {
        match component {
            Component::Normal(part) => output.push(part),
            Component::CurDir => {}
            Component::RootDir | Component::Prefix(_) | Component::ParentDir => {
                return Err(AppError::Status(StatusCode::FORBIDDEN));
            }
        }
    }
    Ok(output)
}

fn join_relative(parent: &str, name: &str) -> String {
    if parent.is_empty() {
        name.to_string()
    } else {
        format!("{parent}/{name}")
    }
}

fn mime_for_name(name: &str) -> String {
    match name
        .rsplit_once('.')
        .map(|(_, extension)| extension.to_ascii_lowercase())
        .as_deref()
    {
        Some("mp4") => "video/mp4",
        Some("mkv") => "video/x-matroska",
        Some("webm") => "video/webm",
        Some("mov") => "video/quicktime",
        Some("avi") => "video/x-msvideo",
        Some("mp3") => "audio/mpeg",
        Some("m4a") => "audio/mp4",
        Some("wav") => "audio/wav",
        Some("jpg") | Some("jpeg") => "image/jpeg",
        Some("png") => "image/png",
        Some("gif") => "image/gif",
        Some("pdf") => "application/pdf",
        Some("txt") => "text/plain",
        Some("json") => "application/json",
        _ => "application/octet-stream",
    }
    .to_string()
}

fn is_streamable_mime(mime: &str) -> bool {
    mime.starts_with("video/")
        || mime.starts_with("audio/")
        || mime.starts_with("image/")
        || mime == "application/pdf"
        || mime == "text/plain"
}

fn parse_range(
    header: Option<&http::HeaderValue>,
    size: u64,
) -> Result<(u64, u64, bool), AppError> {
    if size == 0 {
        return Ok((0, 0, false));
    }
    let Some(header) = header else {
        return Ok((0, size - 1, false));
    };
    let value = header
        .to_str()
        .map_err(|_| AppError::BadRequest("Invalid Range header".to_string()))?;
    let Some(range) = value.strip_prefix("bytes=") else {
        return Err(AppError::BadRequest("Invalid Range header".to_string()));
    };
    if range.contains(',') {
        return Err(AppError::BadRequest(
            "Multiple ranges are not supported".to_string(),
        ));
    }
    let Some((start_text, end_text)) = range.split_once('-') else {
        return Err(AppError::BadRequest("Invalid Range header".to_string()));
    };
    let (start, end) = if start_text.is_empty() {
        let suffix = end_text
            .parse::<u64>()
            .map_err(|_| AppError::BadRequest("Invalid Range header".to_string()))?;
        if suffix == 0 {
            return Err(AppError::BadRequest("Invalid Range header".to_string()));
        }
        (size.saturating_sub(suffix), size - 1)
    } else {
        let start = start_text
            .parse::<u64>()
            .map_err(|_| AppError::BadRequest("Invalid Range header".to_string()))?;
        if start >= size {
            return Err(AppError::Message(
                StatusCode::RANGE_NOT_SATISFIABLE,
                "Range is outside the file".to_string(),
            ));
        }
        let end = if end_text.is_empty() {
            size - 1
        } else {
            end_text
                .parse::<u64>()
                .map_err(|_| AppError::BadRequest("Invalid Range header".to_string()))?
                .min(size - 1)
        };
        if end < start {
            return Err(AppError::BadRequest("Invalid Range header".to_string()));
        }
        (start, end)
    };
    Ok((start, end, true))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_open_ended_range() {
        assert_eq!(
            parse_range(Some(&http::HeaderValue::from_static("bytes=10-")), 100).unwrap(),
            (10, 99, true)
        );
    }

    #[test]
    fn parses_suffix_range() {
        assert_eq!(
            parse_range(Some(&http::HeaderValue::from_static("bytes=-10")), 100).unwrap(),
            (90, 99, true)
        );
    }

    #[test]
    fn rejects_multiple_ranges() {
        assert!(parse_range(Some(&http::HeaderValue::from_static("bytes=0-1,4-5")), 100).is_err());
    }

    #[test]
    fn rejects_parent_path_components() {
        assert!(normalize_relative("../secret").is_err());
        assert!(normalize_relative("folder/../../secret").is_err());
    }

    #[test]
    fn allows_nested_relative_path() {
        assert_eq!(
            normalize_relative("folder/movie.mp4").unwrap(),
            PathBuf::from("folder/movie.mp4")
        );
    }
}
