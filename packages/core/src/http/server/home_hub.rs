use crate::http::server::common::collect_to_json::CollectToJson;
use crate::http::server::common::error::AppError;
use crate::http::server::common::response::{BoxedBody, JsonResponse};
use crate::http::server::{AppState, RequestClientInfo};
use hyper::body::Incoming;
use hyper::{Request, Response, StatusCode};
use serde::{Deserialize, Serialize};
use std::collections::HashSet;
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::{mpsc, oneshot, RwLock};
use uuid::Uuid;

const INVITE_TIMEOUT: Duration = Duration::from_secs(120);
const MAX_TEXT_LENGTH: usize = 256;
const MAX_CHAT_LENGTH: usize = 4096;
const MAX_TRANSFER_FILES: usize = 128;
const MAX_GUEST_LIFETIME: Duration = Duration::from_secs(7 * 24 * 60 * 60);

/// Configuration for the local Home Hub HTTP endpoints.
pub struct HomeHubConfig {
    /// Events are delivered to the application for an explicit user decision.
    pub event_tx: mpsc::Sender<HomeHubEvent>,
    /// Group IDs this device is currently authorized to use for group events.
    pub allowed_group_ids: Vec<String>,
}

/// Requests that must be approved by the local application before the HTTP
/// request is completed. The Rust server remains the authority on identity and
/// request validity; Flutter only decides whether the already validated invite
/// is accepted.
#[derive(Debug)]
pub enum HomeHubEvent {
    InviteRequest {
        ip: super::PeerIp,
        invite_id: String,
        group_id: String,
        group_name: String,
        sender_device_id: String,
        sender_alias: String,
        role: String,
        created_at: String,
        expires_at: Option<String>,
        decision_tx: oneshot::Sender<bool>,
    },
    ChatMessage {
        event_id: String,
        group_id: String,
        sender_device_id: String,
        sender_alias: String,
        text: String,
        created_at: String,
    },
    TransferOffer {
        ip: super::PeerIp,
        offer_id: String,
        group_id: String,
        sender_device_id: String,
        sender_alias: String,
        files: Vec<HomeHubTransferFile>,
        decision_tx: oneshot::Sender<bool>,
    },
}

pub(crate) struct HomeHubState {
    pub(crate) event_tx: mpsc::Sender<HomeHubEvent>,
    pub(crate) allowed_group_ids: Arc<RwLock<HashSet<String>>>,
}

impl HomeHubState {
    pub(crate) fn new(config: HomeHubConfig) -> Self {
        Self {
            event_tx: config.event_tx,
            allowed_group_ids: Arc::new(RwLock::new(
                config
                    .allowed_group_ids
                    .into_iter()
                    .filter(|id| !id.trim().is_empty())
                    .collect(),
            )),
        }
    }

    pub(crate) async fn set_allowed_group_ids(&self, group_ids: Vec<String>) {
        let mut allowed = self.allowed_group_ids.write().await;
        *allowed = group_ids
            .into_iter()
            .filter(|id| !id.trim().is_empty())
            .collect();
    }
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct InviteRequest {
    invite_id: String,
    group_id: String,
    group_name: String,
    sender_device_id: String,
    sender_alias: String,
    role: String,
    created_at: String,
    #[serde(default)]
    expires_at: Option<String>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct InviteResponse {
    invite_id: String,
    accepted: bool,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct EventResponse {
    event_id: String,
    accepted: bool,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct ChatMessageRequest {
    event_id: String,
    group_id: String,
    sender_device_id: String,
    sender_alias: String,
    text: String,
    created_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct HomeHubTransferFile {
    pub file_id: String,
    pub name: String,
    pub size: u64,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct TransferOfferRequest {
    offer_id: String,
    group_id: String,
    sender_device_id: String,
    sender_alias: String,
    files: Vec<HomeHubTransferFile>,
}

fn valid_text(value: &str) -> bool {
    let trimmed = value.trim();
    !trimmed.is_empty() && trimmed.chars().count() <= MAX_TEXT_LENGTH
}

fn validate_expiry(role: &str, expires_at: Option<&str>) -> Result<(), AppError> {
    let parsed = match expires_at {
        Some(value) => Some(
            time::OffsetDateTime::parse(value, &time::format_description::well_known::Rfc3339)
                .map_err(|_| AppError::BadRequest("Invalid expiresAt".to_string()))?,
        ),
        None => None,
    };

    if role == "guest" && parsed.is_none() {
        return Err(AppError::BadRequest(
            "Guest invitations require expiresAt".to_string(),
        ));
    }

    if let Some(expiry) = parsed {
        let now = time::OffsetDateTime::now_utc();
        if expiry <= now {
            return Err(AppError::Message(
                StatusCode::GONE,
                "Home Hub invitation has expired".to_string(),
            ));
        }
        if role == "guest"
            && expiry - now > time::Duration::seconds(MAX_GUEST_LIFETIME.as_secs() as i64)
        {
            return Err(AppError::BadRequest(
                "Guest invitation lifetime is too long".to_string(),
            ));
        }
    }
    Ok(())
}

pub(crate) async fn chat_event(
    req: Request<Incoming>,
    state: AppState,
    client_info: RequestClientInfo,
) -> Result<Response<BoxedBody>, AppError> {
    let Some(home_hub) = state.home_hub else {
        return Err(AppError::Status(StatusCode::NOT_FOUND));
    };
    let payload = req
        .into_body()
        .collect_to_json::<ChatMessageRequest>()
        .await?;
    let ChatMessageRequest {
        event_id,
        group_id,
        sender_device_id,
        sender_alias,
        text,
        created_at,
    } = payload;
    let Some(cert_fingerprint) = client_info.cert_fingerprint() else {
        return Err(AppError::Message(
            StatusCode::UNAUTHORIZED,
            "Home Hub requires the authenticated LocalSend TLS channel".to_string(),
        ));
    };
    if !cert_fingerprint.eq_ignore_ascii_case(sender_device_id.trim()) {
        return Err(AppError::Message(
            StatusCode::FORBIDDEN,
            "Home Hub sender identity does not match its certificate".to_string(),
        ));
    }
    if Uuid::parse_str(event_id.trim()).is_err() || Uuid::parse_str(group_id.trim()).is_err() {
        return Err(AppError::BadRequest(
            "Home Hub event IDs must be UUIDs".to_string(),
        ));
    }
    if !home_hub
        .allowed_group_ids
        .read()
        .await
        .contains(group_id.trim())
    {
        return Err(AppError::Message(
            StatusCode::FORBIDDEN,
            "Home Hub sender is not an authorized member of this group".to_string(),
        ));
    }
    if !valid_text(&sender_alias)
        || text.trim().is_empty()
        || text.chars().count() > MAX_CHAT_LENGTH
    {
        return Err(AppError::BadRequest(
            "Home Hub chat message is empty or oversized".to_string(),
        ));
    }
    time::OffsetDateTime::parse(
        created_at.trim(),
        &time::format_description::well_known::Rfc3339,
    )
    .map_err(|_| AppError::BadRequest("Invalid createdAt".to_string()))?;
    let event_id = event_id.trim().to_string();
    home_hub
        .event_tx
        .send(HomeHubEvent::ChatMessage {
            event_id: event_id.clone(),
            group_id: group_id.trim().to_string(),
            sender_device_id: cert_fingerprint,
            sender_alias: sender_alias.trim().to_string(),
            text: text.trim().to_string(),
            created_at: created_at.trim().to_string(),
        })
        .await
        .map_err(|_| AppError::Status(StatusCode::INTERNAL_SERVER_ERROR))?;
    Ok(JsonResponse {
        status: StatusCode::OK,
        body: EventResponse {
            event_id,
            accepted: true,
        },
    }
    .into_response())
}

pub(crate) async fn transfer_offer(
    req: Request<Incoming>,
    state: AppState,
    client_info: RequestClientInfo,
) -> Result<Response<BoxedBody>, AppError> {
    let Some(home_hub) = state.home_hub else {
        return Err(AppError::Status(StatusCode::NOT_FOUND));
    };
    let payload = req
        .into_body()
        .collect_to_json::<TransferOfferRequest>()
        .await?;
    let TransferOfferRequest {
        offer_id,
        group_id,
        sender_device_id,
        sender_alias,
        files,
    } = payload;
    let Some(cert_fingerprint) = client_info.cert_fingerprint() else {
        return Err(AppError::Message(
            StatusCode::UNAUTHORIZED,
            "Home Hub requires the authenticated LocalSend TLS channel".to_string(),
        ));
    };
    if !cert_fingerprint.eq_ignore_ascii_case(sender_device_id.trim()) {
        return Err(AppError::Message(
            StatusCode::FORBIDDEN,
            "Home Hub sender identity does not match its certificate".to_string(),
        ));
    }
    if Uuid::parse_str(offer_id.trim()).is_err() || Uuid::parse_str(group_id.trim()).is_err() {
        return Err(AppError::BadRequest(
            "Home Hub offer IDs must be UUIDs".to_string(),
        ));
    }
    if !home_hub
        .allowed_group_ids
        .read()
        .await
        .contains(group_id.trim())
    {
        return Err(AppError::Message(
            StatusCode::FORBIDDEN,
            "Home Hub sender is not an authorized member of this group".to_string(),
        ));
    }
    if !valid_text(&sender_alias) || files.is_empty() || files.len() > MAX_TRANSFER_FILES {
        return Err(AppError::BadRequest(
            "Home Hub offer has invalid file metadata".to_string(),
        ));
    }
    for file in &files {
        if !valid_text(&file.file_id) || !valid_text(&file.name) {
            return Err(AppError::BadRequest(
                "Home Hub offer has an invalid file".to_string(),
            ));
        }
    }
    let offer_id = offer_id.trim().to_string();
    let (decision_tx, decision_rx) = oneshot::channel();
    home_hub
        .event_tx
        .send(HomeHubEvent::TransferOffer {
            ip: client_info.ip,
            offer_id: offer_id.clone(),
            group_id: group_id.trim().to_string(),
            sender_device_id: cert_fingerprint,
            sender_alias: sender_alias.trim().to_string(),
            files,
            decision_tx,
        })
        .await
        .map_err(|_| AppError::Status(StatusCode::INTERNAL_SERVER_ERROR))?;
    let accepted = match tokio::time::timeout(INVITE_TIMEOUT, decision_rx).await {
        Ok(result) => result.map_err(|_| AppError::Status(StatusCode::INTERNAL_SERVER_ERROR))?,
        Err(_) => {
            return Err(AppError::Message(
                StatusCode::REQUEST_TIMEOUT,
                "Home Hub transfer approval timed out".to_string(),
            ));
        }
    };
    Ok(JsonResponse {
        status: StatusCode::OK,
        body: EventResponse {
            event_id: offer_id,
            accepted,
        },
    }
    .into_response())
}

pub(crate) async fn invite(
    req: Request<Incoming>,
    state: AppState,
    client_info: RequestClientInfo,
) -> Result<Response<BoxedBody>, AppError> {
    let Some(home_hub) = state.home_hub else {
        return Err(AppError::Status(StatusCode::NOT_FOUND));
    };

    let payload = req.into_body().collect_to_json::<InviteRequest>().await?;
    let InviteRequest {
        invite_id,
        group_id,
        group_name,
        sender_device_id,
        sender_alias,
        role,
        created_at,
        expires_at,
    } = payload;

    // Device IDs for Home Hub are the SHA-256 certificate fingerprints. An
    // unsigned HTTP request cannot establish this identity, so it must not be
    // allowed to create a membership invitation.
    let Some(cert_fingerprint) = client_info.cert_fingerprint() else {
        return Err(AppError::Message(
            StatusCode::UNAUTHORIZED,
            "Home Hub requires the authenticated LocalSend TLS channel".to_string(),
        ));
    };
    if !cert_fingerprint.eq_ignore_ascii_case(sender_device_id.trim()) {
        return Err(AppError::Message(
            StatusCode::FORBIDDEN,
            "Home Hub sender identity does not match its certificate".to_string(),
        ));
    }

    if !valid_text(&invite_id)
        || !valid_text(&group_id)
        || !valid_text(&group_name)
        || !valid_text(&sender_device_id)
        || !valid_text(&sender_alias)
        || !valid_text(&created_at)
    {
        return Err(AppError::BadRequest(
            "Home Hub invitation contains an empty or oversized field".to_string(),
        ));
    }
    if Uuid::parse_str(invite_id.trim()).is_err() || Uuid::parse_str(group_id.trim()).is_err() {
        return Err(AppError::BadRequest(
            "Home Hub invitation IDs must be UUIDs".to_string(),
        ));
    }
    if !matches!(role.as_str(), "sender" | "viewer" | "guest") {
        return Err(AppError::BadRequest(
            "Home Hub invitation role is not allowed".to_string(),
        ));
    }
    time::OffsetDateTime::parse(
        created_at.trim(),
        &time::format_description::well_known::Rfc3339,
    )
    .map_err(|_| AppError::BadRequest("Invalid createdAt".to_string()))?;
    validate_expiry(&role, expires_at.as_deref())?;

    let invite_id = invite_id.trim().to_string();
    let expiry_for_post_approval = expires_at.clone();
    let (decision_tx, decision_rx) = oneshot::channel();
    home_hub
        .event_tx
        .send(HomeHubEvent::InviteRequest {
            ip: client_info.ip,
            invite_id: invite_id.clone(),
            group_id: group_id.trim().to_string(),
            group_name: group_name.trim().to_string(),
            sender_device_id: cert_fingerprint,
            sender_alias: sender_alias.trim().to_string(),
            role,
            created_at: created_at.trim().to_string(),
            expires_at,
            decision_tx,
        })
        .await
        .map_err(|_| AppError::Status(StatusCode::INTERNAL_SERVER_ERROR))?;

    let accepted = match tokio::time::timeout(INVITE_TIMEOUT, decision_rx).await {
        Ok(result) => result.map_err(|_| AppError::Status(StatusCode::INTERNAL_SERVER_ERROR))?,
        Err(_) => {
            return Err(AppError::Message(
                StatusCode::REQUEST_TIMEOUT,
                "Home Hub invitation approval timed out".to_string(),
            ));
        }
    };

    // A guest invite can expire while it waits in the UI. Do not let a late
    // approval create a valid membership after its server-side expiry.
    if accepted && expires_at_is_expired(expiry_for_post_approval.as_deref()) {
        return Err(AppError::Message(
            StatusCode::GONE,
            "Home Hub invitation expired before approval".to_string(),
        ));
    }

    Ok(JsonResponse {
        status: StatusCode::OK,
        body: InviteResponse {
            invite_id,
            accepted,
        },
    }
    .into_response())
}

fn expires_at_is_expired(value: Option<&str>) -> bool {
    let Some(value) = value else {
        return false;
    };
    let Ok(expiry) =
        time::OffsetDateTime::parse(value, &time::format_description::well_known::Rfc3339)
    else {
        return true;
    };
    expiry <= time::OffsetDateTime::now_utc()
}
