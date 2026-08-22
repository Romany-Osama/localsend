//! Integration tests for the local Home Hub invitation control plane.

use localsend::http::client::LsHttpClientV2;
use localsend::http::server::home_hub::{HomeHubConfig, HomeHubEvent};
use localsend::http::server::v2::ServerEventV2;
use localsend::http::server::{start_with_port_and_home_hub, ServerConfigV2, TlsConfig};
use localsend::http::state::ClientInfo;
use localsend::model::discovery::ProtocolType;
use std::time::Duration;
use tokio::sync::{mpsc, oneshot};

struct Identity {
    cert: String,
    private_key: String,
    fingerprint: String,
}

fn identity() -> Identity {
    let cert = localsend::crypto::cert::generate_self_signed().unwrap();
    Identity {
        cert: cert.certificate_pem,
        private_key: cert.private_key_pem,
        fingerprint: cert.fingerprint,
    }
}

async fn start_server(
    identity: &Identity,
    allowed_group_ids: Vec<String>,
) -> (
    localsend::http::server::ServerHandle,
    mpsc::Receiver<HomeHubEvent>,
    oneshot::Sender<()>,
) {
    let (home_tx, home_rx) = mpsc::channel(16);
    let (v2_tx, _v2_rx) = mpsc::channel::<ServerEventV2>(16);
    let (stop_tx, stop_rx) = oneshot::channel();
    let handle = start_with_port_and_home_hub(
        0,
        Some(TlsConfig {
            cert: identity.cert.clone(),
            private_key: identity.private_key.clone(),
        }),
        ClientInfo {
            alias: "Home Hub Test Server".to_string(),
            version: "2.2".to_string(),
            device_model: Some("Rust".to_string()),
            device_type: None,
            token: identity.fingerprint.clone(),
        },
        None,
        Some(ServerConfigV2 {
            pin: None,
            verify_checksums: true,
            event_tx: v2_tx,
        }),
        None,
        Some(HomeHubConfig {
            event_tx: home_tx,
            allowed_group_ids,
        }),
        stop_rx,
    )
    .await
    .unwrap();
    (handle, home_rx, stop_tx)
}

fn client(identity: &Identity, expected: &str) -> LsHttpClientV2 {
    LsHttpClientV2::try_new(
        &identity.private_key,
        &identity.cert,
        Some(expected.to_string()),
        None,
    )
    .unwrap()
}

fn body(sender: &Identity, role: &str, expires_at: Option<String>) -> serde_json::Value {
    serde_json::json!({
        "inviteId": uuid::Uuid::new_v4().to_string(),
        "groupId": uuid::Uuid::new_v4().to_string(),
        "groupName": "Family",
        "senderDeviceId": sender.fingerprint,
        "senderAlias": "Sender",
        "role": role,
        "createdAt": "2026-08-22T12:00:00Z",
        "expiresAt": expires_at,
    })
}

#[tokio::test]
async fn invite_is_emitted_only_after_authenticated_validation_and_can_be_accepted() {
    let server_identity = identity();
    let sender_identity = identity();
    let (handle, mut home_rx, stop_tx) = start_server(&server_identity, Vec::new()).await;
    let sender = client(&sender_identity, &server_identity.fingerprint);
    let invite = body(&sender_identity, "viewer", None);
    let invite_id = invite["inviteId"].as_str().unwrap().to_string();

    let decision = tokio::spawn(async move {
        let event = tokio::time::timeout(Duration::from_secs(2), home_rx.recv())
            .await
            .unwrap()
            .unwrap();
        match event {
            HomeHubEvent::InviteRequest {
                sender_device_id,
                role,
                decision_tx,
                ..
            } => {
                assert_eq!(sender_device_id, sender_identity.fingerprint);
                assert_eq!(role, "viewer");
                decision_tx.send(true).unwrap();
            }
            HomeHubEvent::ChatMessage { .. } => panic!("expected invite event"),
            HomeHubEvent::TransferOffer { .. } => panic!("expected invite event"),
        }
    });

    let response = sender
        .post_json(
            ProtocolType::Https,
            "127.0.0.1",
            handle.port(),
            "/home-hub/v1/invite",
            invite,
        )
        .await
        .unwrap();
    assert_eq!(response["inviteId"], invite_id);
    assert_eq!(response["accepted"], true);
    decision.await.unwrap();
    let _ = stop_tx.send(());
    handle.wait_stopped().await;
}

#[tokio::test]
async fn invite_rejects_a_sender_device_id_that_does_not_match_its_certificate() {
    let server_identity = identity();
    let sender_identity = identity();
    let forged_identity = identity();
    let (handle, mut home_rx, stop_tx) = start_server(&server_identity, Vec::new()).await;
    let sender = client(&sender_identity, &server_identity.fingerprint);
    let mut invite = body(&sender_identity, "viewer", None);
    invite["senderDeviceId"] = serde_json::json!(forged_identity.fingerprint);

    let error = sender
        .post_json(
            ProtocolType::Https,
            "127.0.0.1",
            handle.port(),
            "/home-hub/v1/invite",
            invite,
        )
        .await
        .unwrap_err();
    match error {
        localsend::http::client::ClientError::StatusCode(status) => assert_eq!(status.status, 403),
        other => panic!("expected HTTP 403, got {other:?}"),
    }
    assert!(
        tokio::time::timeout(Duration::from_millis(150), home_rx.recv())
            .await
            .is_err()
    );
    let _ = stop_tx.send(());
    handle.wait_stopped().await;
}

#[tokio::test]
async fn expired_guest_invite_is_rejected_before_the_application_event() {
    let server_identity = identity();
    let sender_identity = identity();
    let (handle, mut home_rx, stop_tx) = start_server(&server_identity, Vec::new()).await;
    let sender = client(&sender_identity, &server_identity.fingerprint);
    let invite = body(
        &sender_identity,
        "guest",
        Some("2026-08-22T11:00:00Z".to_string()),
    );

    let error = sender
        .post_json(
            ProtocolType::Https,
            "127.0.0.1",
            handle.port(),
            "/home-hub/v1/invite",
            invite,
        )
        .await
        .unwrap_err();
    match error {
        localsend::http::client::ClientError::StatusCode(status) => assert_eq!(status.status, 410),
        other => panic!("expected HTTP 410, got {other:?}"),
    }
    assert!(
        tokio::time::timeout(Duration::from_millis(150), home_rx.recv())
            .await
            .is_err()
    );
    let _ = stop_tx.send(());
    handle.wait_stopped().await;
}

#[tokio::test]
async fn invite_rejects_plain_http_without_emitting_an_application_event() {
    let identity = identity();
    let (home_tx, mut home_rx) = mpsc::channel(16);
    let (v2_tx, _v2_rx) = mpsc::channel::<ServerEventV2>(16);
    let (stop_tx, stop_rx) = oneshot::channel();
    let handle = start_with_port_and_home_hub(
        0,
        None,
        ClientInfo {
            alias: "Plain HTTP Test Server".to_string(),
            version: "2.2".to_string(),
            device_model: Some("Rust".to_string()),
            device_type: None,
            token: identity.fingerprint.clone(),
        },
        None,
        Some(ServerConfigV2 {
            pin: None,
            verify_checksums: true,
            event_tx: v2_tx,
        }),
        None,
        Some(HomeHubConfig {
            event_tx: home_tx,
            allowed_group_ids: Vec::new(),
        }),
        stop_rx,
    )
    .await
    .unwrap();

    let response = reqwest::Client::new()
        .post(format!(
            "http://127.0.0.1:{}/api/localsend/v2/home-hub/v1/invite",
            handle.port()
        ))
        .json(&body(&identity, "viewer", None))
        .send()
        .await
        .unwrap();
    assert_eq!(response.status(), reqwest::StatusCode::UNAUTHORIZED);
    assert!(
        tokio::time::timeout(Duration::from_millis(150), home_rx.recv())
            .await
            .is_err()
    );
    let _ = stop_tx.send(());
    handle.wait_stopped().await;
}

#[tokio::test]
async fn authenticated_chat_event_reaches_the_application_stream() {
    let server_identity = identity();
    let sender_identity = identity();
    let event_id = uuid::Uuid::new_v4().to_string();
    let group_id = uuid::Uuid::new_v4().to_string();
    let (handle, mut home_rx, stop_tx) =
        start_server(&server_identity, vec![group_id.clone()]).await;
    let sender = client(&sender_identity, &server_identity.fingerprint);
    let payload = serde_json::json!({
        "eventId": event_id,
        "groupId": group_id,
        "senderDeviceId": sender_identity.fingerprint,
        "senderAlias": "Sender",
        "text": "hello from LAN",
        "createdAt": "2026-08-22T12:00:00Z",
    });

    let response = sender
        .post_json(
            ProtocolType::Https,
            "127.0.0.1",
            handle.port(),
            "/home-hub/v1/events",
            payload,
        )
        .await
        .unwrap();
    assert_eq!(response["eventId"], event_id);
    assert_eq!(response["accepted"], true);

    let event = tokio::time::timeout(Duration::from_secs(2), home_rx.recv())
        .await
        .unwrap()
        .unwrap();
    match event {
        HomeHubEvent::ChatMessage {
            event_id: received_id,
            group_id: received_group,
            text,
            ..
        } => {
            assert_eq!(received_id, event_id);
            assert_eq!(received_group, group_id);
            assert_eq!(text, "hello from LAN");
        }
        HomeHubEvent::InviteRequest { .. } => panic!("expected chat event"),
        HomeHubEvent::TransferOffer { .. } => panic!("expected chat event"),
    }
    let _ = stop_tx.send(());
    handle.wait_stopped().await;
}

#[tokio::test]
async fn chat_for_a_group_outside_the_allow_list_is_rejected() {
    let server_identity = identity();
    let sender_identity = identity();
    let allowed_group_id = uuid::Uuid::new_v4().to_string();
    let unauthorized_group_id = uuid::Uuid::new_v4().to_string();
    let (handle, mut home_rx, stop_tx) =
        start_server(&server_identity, vec![allowed_group_id]).await;
    let sender = client(&sender_identity, &server_identity.fingerprint);
    let payload = serde_json::json!({
        "eventId": uuid::Uuid::new_v4().to_string(),
        "groupId": unauthorized_group_id,
        "senderDeviceId": sender_identity.fingerprint,
        "senderAlias": "Sender",
        "text": "must not cross group boundary",
        "createdAt": "2026-08-22T12:00:00Z",
    });

    let error = sender
        .post_json(
            ProtocolType::Https,
            "127.0.0.1",
            handle.port(),
            "/home-hub/v1/events",
            payload,
        )
        .await
        .unwrap_err();
    match error {
        localsend::http::client::ClientError::StatusCode(status) => assert_eq!(status.status, 403),
        other => panic!("expected HTTP 403, got {other:?}"),
    }
    assert!(
        tokio::time::timeout(Duration::from_millis(150), home_rx.recv())
            .await
            .is_err()
    );
    let _ = stop_tx.send(());
    handle.wait_stopped().await;
}

#[tokio::test]
async fn transfer_offer_waits_for_this_recipient_decision() {
    let server_identity = identity();
    let sender_identity = identity();
    let offer_id = uuid::Uuid::new_v4().to_string();
    let group_id = uuid::Uuid::new_v4().to_string();
    let (handle, mut home_rx, stop_tx) =
        start_server(&server_identity, vec![group_id.clone()]).await;
    let sender = client(&sender_identity, &server_identity.fingerprint);
    let payload = serde_json::json!({
        "offerId": offer_id,
        "groupId": group_id,
        "senderDeviceId": sender_identity.fingerprint,
        "senderAlias": "Sender",
        "files": [{"fileId": "f-1", "name": "video.mp4", "size": 1024}],
    });

    let expected_offer_id = offer_id.clone();
    let expected_group_id = group_id.clone();
    let decision_task = tokio::spawn(async move {
        let event = tokio::time::timeout(Duration::from_secs(2), home_rx.recv())
            .await
            .unwrap()
            .unwrap();
        match event {
            HomeHubEvent::TransferOffer {
                offer_id: received_id,
                group_id: received_group,
                files,
                decision_tx,
                ..
            } => {
                assert_eq!(received_id, expected_offer_id);
                assert_eq!(received_group, expected_group_id);
                assert_eq!(files[0].name, "video.mp4");
                decision_tx.send(true).unwrap();
            }
            HomeHubEvent::InviteRequest { .. } | HomeHubEvent::ChatMessage { .. } => {
                panic!("expected transfer offer")
            }
        }
    });

    let response = sender
        .post_json(
            ProtocolType::Https,
            "127.0.0.1",
            handle.port(),
            "/home-hub/v1/transfers/offer",
            payload,
        )
        .await
        .unwrap();
    assert_eq!(response["eventId"], offer_id);
    assert_eq!(response["accepted"], true);
    decision_task.await.unwrap();
    let _ = stop_tx.send(());
    handle.wait_stopped().await;
}
