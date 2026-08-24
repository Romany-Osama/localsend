# BaytBeam

[![CI status][ci-badge]][ci-workflow]
[![Release][release-badge]][release-link]
[![License: Apache-2.0][license-badge]][license-link]

BaytBeam is an independent, open-source home LAN hub built from a [LocalSend](https://github.com/localsend/localsend) fork. It keeps the original LocalSend send, receive, discovery, HTTPS transfer, settings, and sharing flows, while adding optional home-focused features such as **Stream & Browse**, **Home Hub groups**, **local chat**, **per-device approvals**, **guest access**, and **activity controls**.

BaytBeam is designed for direct **LAN/Wi‑Fi communication only**. It does not require a cloud account, internet upload, internet download, or an always-on central home server. Files selected for Stream & Browse stay on the source device and are read only after the source approves the session and each requested file.

> **Important:** BaytBeam is not an official LocalSend release and is not affiliated with or endorsed by the LocalSend project. The original LocalSend attribution and license notices remain in this repository.

## Why BaytBeam can be installed next to LocalSend

BaytBeam has its own product identity and platform installation identifiers. The Android application ID and Apple bundle ID are `com.baytbeam.app`, Linux uses the `baytbeam` package identity, and the Windows product uses a separate installer ID and `baytbeam_app.exe`. This lets users keep the official LocalSend application installed while trying BaytBeam.

The application artwork is intentionally unchanged from the upstream-based app. The visible product name, package identifiers, installer metadata, release assets, and documentation identify this build as **BaytBeam**.

## Features

### Original LocalSend functionality

BaytBeam retains nearby-device discovery, file and text transfer, transfer approval, HTTPS encryption, share-sheet integration, receive progress, the existing transfer resume behavior, and the original platform targets. The underlying LocalSend protocol and internal Rust/Flutter isolate names remain where changing them would add compatibility risk.

### Home Hub

Home Hub adds local groups with viewer, sender, owner, and time-limited guest roles. Invitations require approval on the target device. Chat messages are stored locally and maintain an outbox and per-peer delivery state. Revoke All clears local guest permissions, pending invitations, and relevant outbox state, then records the action in the local activity log.

Group broadcast reuses the original LocalSend transfer session for every recipient. Each recipient therefore receives an independent approval request and can accept or reject without the group owner being able to force a file onto that device.

### Stream & Browse

A device can publish a selected local directory. Another device can request a read-only temporary browsing session, and the source device must approve the session. Every file request is approved separately before a short-lived grant is issued. The source remains the storage location; BaytBeam does not copy the file to a cloud service just to play or browse it.

## Network and privacy model

BaytBeam uses direct peer addresses discovered on the local network and HTTPS/mTLS identity checks. Home Hub endpoints are not a cloud relay. A router, firewall, guest-network isolation, VPN, or port forwarding configuration can still change what devices can reach; users should keep the app on a trusted home network and avoid exposing its port to the public internet.

The optional WebRTC signaling path remains separate and disabled by default. Wi‑Fi voice calls are not part of this release.

## Current limitations

The Home Hub outbox does not yet automatically resend when an offline peer returns. Activity history is local rather than synchronized across all devices. Revoke All currently applies locally and does not provide a complete remote-session notification protocol. Group membership authorization still uses the local certificate identity and group allow-list rather than an owner-signed cross-device membership snapshot.

The current BroadcastPage uses the original LocalSend per-recipient approval flow directly. The Home Hub transfer-offer endpoint is available as an independently tested control-plane component, but it is not an obligatory preflight stage for the current broadcast UI.

## Downloads

Download the latest branded assets from the [BaytBeam releases page][release-link]. Android releases are split by ABI. Windows provides a portable ZIP and installer EXE. Linux provides x64 and arm64 packages where the workflow supports them. macOS and iOS archives are unsigned in the public CI release unless the maintainer supplies Apple signing credentials.

The original upstream-based release `v1.18.2-stream.9` remains available separately. BaytBeam releases use a distinct tag and artifact prefix and do not replace the upstream-based release.

## Building from source

Requirements include Flutter 3.41.x, Dart 3.11.x, Rust stable, and the platform dependencies required by Flutter and `media_kit`.

```bash
cd app
flutter pub get
flutter run
```

For a release build, use the platform command appropriate to the target. The project keeps the Dart package and Rust FFI library names stable internally, so package imports and generated bridge code remain compatible with the fork changes.

```bash
flutter build apk --release --split-per-abi
flutter build windows --release
flutter build linux --release
flutter build macos --release
flutter build ios --release --no-codesign
```

Android releases should use a maintainer-controlled keystore. A self-signed Windows certificate can identify the BaytBeam publisher but will still produce a SmartScreen trust warning until that certificate is installed or replaced by a publicly trusted code-signing certificate. This fork keeps the maintainer key material outside Git; CI uses it only through the `BAYTBEAM_ANDROID_*` and `BAYTBEAM_WINDOWS_*` repository secrets. Apple device-installable builds require the maintainer's Apple Developer certificates and provisioning profiles.

## Contributing

Pull requests and issue reports are welcome. Please clearly state whether a change belongs to the original LocalSend-compatible flow or to BaytBeam Home Hub. Do not remove upstream copyright, attribution, license, or trademark notices from files derived from LocalSend.

## License and attribution

The repository remains licensed under the **Apache License 2.0**. This is the upstream-compatible open-source license retained for the derivative work; the `NOTICE` file explains the BaytBeam fork identity and the distinction from official LocalSend releases. See [LICENSE][license-link].

[ci-badge]: https://github.com/Romany-Osama/localsend/actions/workflows/stream-browse-release-full.yml/badge.svg
[ci-workflow]: https://github.com/Romany-Osama/localsend/actions/workflows/stream-browse-release-full.yml
[release-badge]: https://img.shields.io/github/v/release/Romany-Osama/localsend?label=BaytBeam%20release
[release-link]: https://github.com/Romany-Osama/localsend/releases
[license-badge]: https://img.shields.io/badge/license-Apache--2.0-blue.svg
[license-link]: https://github.com/Romany-Osama/localsend/blob/stream-browse/LICENSE
