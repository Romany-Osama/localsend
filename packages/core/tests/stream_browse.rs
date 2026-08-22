#![cfg(feature = "http")]

use localsend::http::server::stream::{StreamConfig, StreamEvent, StreamRoot};
use localsend::http::server::web::{WebConfig, WebI18n, WebPages};
use localsend::http::server::{start_with_port, ServerHandle};
use localsend::http::state::ClientInfo;
use std::path::PathBuf;
use tokio::sync::{mpsc, oneshot};
use tokio::time::{timeout, Duration};

enum PendingRequest {
    Session(oneshot::Sender<bool>),
    File(oneshot::Sender<bool>),
}

struct TestServer {
    handle: ServerHandle,
    stop_tx: oneshot::Sender<()>,
    root: PathBuf,
}

async fn start_test_server() -> (TestServer, mpsc::Receiver<PendingRequest>) {
    let root = std::env::temp_dir().join(format!("localsend-stream-{}", uuid::Uuid::new_v4()));
    tokio::fs::create_dir_all(&root).await.unwrap();
    tokio::fs::write(root.join("movie.mp4"), b"0123456789")
        .await
        .unwrap();
    tokio::fs::write(root.join("empty.mp4"), b"").await.unwrap();

    let (event_tx, mut event_rx) = mpsc::channel::<StreamEvent>(16);
    let (pending_tx, pending_rx) = mpsc::channel::<PendingRequest>(16);
    tokio::spawn(async move {
        while let Some(event) = event_rx.recv().await {
            let pending = match event {
                StreamEvent::PrepareSession { decision_tx, .. } => {
                    PendingRequest::Session(decision_tx)
                }
                StreamEvent::FileRequest { decision_tx, .. } => PendingRequest::File(decision_tx),
            };
            if pending_tx.send(pending).await.is_err() {
                break;
            }
        }
    });

    let (stop_tx, stop_rx) = oneshot::channel();
    let handle = start_with_port(
        0,
        None,
        ClientInfo {
            alias: "Stream Test Server".to_string(),
            version: "test".to_string(),
            device_model: Some("Rust test".to_string()),
            device_type: None,
            token: "test-fingerprint".to_string(),
        },
        None,
        None,
        Some(WebConfig {
            send: None,
            stream: Some(StreamConfig {
                roots: vec![StreamRoot {
                    id: "root-1".to_string(),
                    name: "Test root".to_string(),
                    path: root.clone(),
                }],
                event_tx,
            }),
            upload: false,
            i18n: WebI18n::default(),
            pages: WebPages::default(),
        }),
        stop_rx,
    )
    .await
    .unwrap();

    (
        TestServer {
            handle,
            stop_tx,
            root,
        },
        pending_rx,
    )
}

async fn stop_test_server(server: TestServer) {
    let _ = server.stop_tx.send(());
    server.handle.wait_stopped().await;
    let _ = tokio::fs::remove_dir_all(server.root).await;
}

async fn next_pending(rx: &mut mpsc::Receiver<PendingRequest>) -> PendingRequest {
    timeout(Duration::from_secs(2), rx.recv())
        .await
        .expect("approval event timed out")
        .expect("approval event channel closed")
}

#[tokio::test]
async fn approval_gates_browse_file_range_empty_file_and_revoke() {
    let (server, mut pending_rx) = start_test_server().await;
    let client = localsend::reqwest::Client::new();
    let base = format!("http://127.0.0.1:{}", server.handle.port());

    let mut session_request = tokio::spawn(
        client
            .post(format!("{base}/api/localsend/stream/v1/session"))
            .json(&serde_json::json!({"userAgent": "integration-test"}))
            .send(),
    );
    let session_decision = match next_pending(&mut pending_rx).await {
        PendingRequest::Session(decision) => decision,
        PendingRequest::File(_) => panic!("file approval arrived before session approval"),
    };
    assert!(timeout(Duration::from_millis(50), &mut session_request)
        .await
        .is_err());
    session_decision.send(true).unwrap();
    let session_response = session_request.await.unwrap().unwrap();
    assert_eq!(session_response.status(), 200);
    let session: serde_json::Value = session_response.json().await.unwrap();
    let session_id = session["sessionId"].as_str().unwrap().to_string();

    let roots_response = client
        .get(format!(
            "{base}/api/localsend/stream/v1/roots?sessionId={session_id}"
        ))
        .send()
        .await
        .unwrap();
    assert_eq!(roots_response.status(), 200);
    let roots: serde_json::Value = roots_response.json().await.unwrap();
    assert_eq!(roots[0]["id"], "root-1");

    let entries_response = client
        .get(format!(
            "{base}/api/localsend/stream/v1/entries?sessionId={session_id}&rootId=root-1"
        ))
        .send()
        .await
        .unwrap();
    assert_eq!(entries_response.status(), 200);
    let entries: serde_json::Value = entries_response.json().await.unwrap();
    assert!(entries
        .as_array()
        .unwrap()
        .iter()
        .any(|entry| entry["name"] == "movie.mp4"));

    let traversal_response = client
        .get(format!("{base}/api/localsend/stream/v1/entries?sessionId={session_id}&rootId=root-1&path=..%2F"))
        .send()
        .await
        .unwrap();
    assert_eq!(traversal_response.status(), 403);

    let mut file_request = tokio::spawn(
        client
            .post(format!("{base}/api/localsend/stream/v1/file-request"))
            .json(&serde_json::json!({
                "sessionId": session_id,
                "rootId": "root-1",
                "path": "movie.mp4",
                "purpose": "play"
            }))
            .send(),
    );
    let file_decision = match next_pending(&mut pending_rx).await {
        PendingRequest::File(decision) => decision,
        PendingRequest::Session(_) => panic!("unexpected second session approval"),
    };
    assert!(timeout(Duration::from_millis(50), &mut file_request)
        .await
        .is_err());
    file_decision.send(true).unwrap();
    let file_response = file_request.await.unwrap().unwrap();
    assert_eq!(file_response.status(), 200);
    let grant: serde_json::Value = file_response.json().await.unwrap();
    let grant_id = grant["grantId"].as_str().unwrap();
    assert_eq!(grant["file"]["rootId"], "root-1");

    let denied_stream = client
        .get(format!(
            "{base}/api/localsend/stream/v1/stream?grantId=not-a-grant"
        ))
        .send()
        .await
        .unwrap();
    assert_eq!(denied_stream.status(), 403);

    let ranged_response = client
        .get(format!(
            "{base}/api/localsend/stream/v1/stream?grantId={grant_id}"
        ))
        .header("range", "bytes=1-3")
        .send()
        .await
        .unwrap();
    assert_eq!(ranged_response.status(), 206);
    assert_eq!(ranged_response.headers()["content-length"], "3");
    assert_eq!(ranged_response.bytes().await.unwrap().as_ref(), b"123");

    let empty_request = tokio::spawn(
        client
            .post(format!("{base}/api/localsend/stream/v1/file-request"))
            .json(&serde_json::json!({
                "sessionId": session_id,
                "rootId": "root-1",
                "path": "empty.mp4",
                "purpose": "play"
            }))
            .send(),
    );
    let empty_decision = match next_pending(&mut pending_rx).await {
        PendingRequest::File(decision) => decision,
        PendingRequest::Session(_) => panic!("unexpected session approval for empty file"),
    };
    empty_decision.send(true).unwrap();
    let empty_response = empty_request.await.unwrap().unwrap();
    assert_eq!(empty_response.status(), 200);
    let empty_grant: serde_json::Value = empty_response.json().await.unwrap();
    let empty_stream = client
        .get(format!(
            "{base}/api/localsend/stream/v1/stream?grantId={}",
            empty_grant["grantId"].as_str().unwrap()
        ))
        .send()
        .await
        .unwrap();
    assert_eq!(empty_stream.status(), 200);
    assert_eq!(empty_stream.headers()["content-length"], "0");
    assert!(empty_stream.bytes().await.unwrap().is_empty());

    let revoke_response = client
        .post(format!(
            "{base}/api/localsend/stream/v1/session/revoke?sessionId={session_id}"
        ))
        .send()
        .await
        .unwrap();
    assert_eq!(revoke_response.status(), 200);
    let after_revoke = client
        .get(format!(
            "{base}/api/localsend/stream/v1/roots?sessionId={session_id}"
        ))
        .send()
        .await
        .unwrap();
    assert_eq!(after_revoke.status(), 403);

    stop_test_server(server).await;
}

#[tokio::test]
async fn rejection_blocks_session_and_file() {
    let (server, mut pending_rx) = start_test_server().await;
    let client = localsend::reqwest::Client::new();
    let base = format!("http://127.0.0.1:{}", server.handle.port());

    let rejected_session = tokio::spawn(
        client
            .post(format!("{base}/api/localsend/stream/v1/session"))
            .json(&serde_json::json!({}))
            .send(),
    );
    let session_decision = match next_pending(&mut pending_rx).await {
        PendingRequest::Session(decision) => decision,
        PendingRequest::File(_) => panic!("file approval arrived before session approval"),
    };
    session_decision.send(false).unwrap();
    assert_eq!(rejected_session.await.unwrap().unwrap().status(), 403);

    let accepted_session = tokio::spawn(
        client
            .post(format!("{base}/api/localsend/stream/v1/session"))
            .json(&serde_json::json!({}))
            .send(),
    );
    let session_decision = match next_pending(&mut pending_rx).await {
        PendingRequest::Session(decision) => decision,
        PendingRequest::File(_) => panic!("file approval arrived before session approval"),
    };
    session_decision.send(true).unwrap();
    let session_response = accepted_session.await.unwrap().unwrap();
    assert_eq!(session_response.status(), 200);
    let session: serde_json::Value = session_response.json().await.unwrap();
    let session_id = session["sessionId"].as_str().unwrap().to_string();

    let rejected_file = tokio::spawn(
        client
            .post(format!("{base}/api/localsend/stream/v1/file-request"))
            .json(&serde_json::json!({
                "sessionId": session_id,
                "rootId": "root-1",
                "path": "movie.mp4"
            }))
            .send(),
    );
    let file_decision = match next_pending(&mut pending_rx).await {
        PendingRequest::File(decision) => decision,
        PendingRequest::Session(_) => panic!("unexpected session approval"),
    };
    file_decision.send(false).unwrap();
    assert_eq!(rejected_file.await.unwrap().unwrap().status(), 403);

    stop_test_server(server).await;
}
