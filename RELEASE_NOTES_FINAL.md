# LocalSend Stream & Browse v1.18.2-stream.9

This release is built from the `Romany-Osama/localsend` fork on the `stream-browse` branch. It preserves LocalSend's original transfer features and adds LAN-only **Stream & Browse** with session approval, per-file approval, temporary read-only grants, HTTP Range streaming, and in-app playback without saving the streamed file on the requesting device.

## Assets

The release includes split Android APKs for `armeabi-v7a`, `arm64-v8a`, and `x86_64`; Linux x64 `.tar.gz`, `.deb`, and `.AppImage` packages; Linux arm64 `.tar.gz` and `.deb` packages; a Windows x64 installer EXE and portable ZIP; an unsigned macOS app ZIP; and an unsigned iOS `.app` ZIP.

## Network and privacy

Stream & Browse connects directly to the source device's discovered local IP and LocalSend HTTP port. It does not upload files to a cloud service or use Internet download for the streamed bytes. The optional original WebRTC signaling path remains disabled by default and is separate from Stream & Browse. Strict isolation from a VPN, port-forward, or permissive firewall still depends on the operating system and network configuration because the LocalSend listener uses wildcard interfaces like the original app.

## Review and verification

The Rust integration tests cover explicit session approval, explicit per-file approval, rejection, path traversal protection, HTTP Range streaming, empty files, and revoke. The full-platform GitHub Actions run `32571134752` passed the verification job and all seven platform build jobs.

## Signing status

The Android APKs use a temporary CI-generated test key for evaluation, not a long-term publisher key. Windows and macOS artifacts are unsigned and may show SmartScreen or Gatekeeper warnings. The iOS artifact is unsigned and is not directly installable as an App Store/TestFlight IPA; it requires an Apple Developer signing certificate and provisioning profile. No physical-device test was performed inside the build environment.
