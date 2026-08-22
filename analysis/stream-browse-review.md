# Stream & Browse review — initial findings

## Confirmed behavior

The Stream & Browse client constructs URLs from the discovered device's direct `ip`, `port`, and `https` fields. The server routes the feature through the existing LocalSend HTTP listener. No cloud upload, public HTTP endpoint, WebSocket, or signaling URL appears in the Stream & Browse client/server path.

The server emits a session approval event before returning a session token, and emits a separate file approval event before creating a read-only grant. The bridge stores one decision sender per pending session/file request and only resolves it through an explicit Dart decision action.

## Findings requiring fixes or explicit limitations

1. The TCP listener binds to IPv4/IPv6 wildcard addresses. This is normal for LAN discovery, but it is not a formal LAN-only firewall boundary. A VPN, port forward, public interface, or permissive firewall could make the listener reachable outside the LAN. The feature does not consume internet bandwidth by itself, but strict LAN-only enforcement needs interface/subnet filtering or an OS firewall rule.
2. `StreamSession` has no expiry timestamp. `GRANT_TTL` is returned for the session, but `validate_session` currently accepts an approved session indefinitely until revoke/server restart. Session expiry should be enforced.
3. Empty files are handled incorrectly: `parse_range` returns `(0, 0, false)` for size zero and `stream_file` advertises `Content-Length: 1` even though the read task emits no byte. This should return a zero-length 200 response.
4. The request and session approval futures have no timeout. A disconnected or unattended client can leave a pending request waiting indefinitely and leave a pending decision entry until server shutdown. A bounded timeout and cleanup should be added.
5. Revoke prevents new requests but does not cancel a stream already spawned. This may be acceptable as a best-effort revoke semantics, but should be documented or changed if immediate cancellation is required.
6. The app's separate optional WebRTC signaling path contains public signaling/STUN defaults, but `webRTCEnabled` is hardcoded false. This is not used by Stream & Browse; a LAN-only claim must distinguish the new feature from that disabled original path.

## Next validation

Run Rust tests and static searches after fixes. Build Linux/macOS/iOS targets where supported by GitHub-hosted runners. Device-level LAN and packet-capture validation still requires real devices or a user-provided test environment.
