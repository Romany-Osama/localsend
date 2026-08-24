# BaytBeam signing and parallel installation

BaytBeam is an independent open-source derivative build based on LocalSend. It deliberately uses different installation identifiers so it can be installed beside the official LocalSend application. The launcher artwork is unchanged; the visible name, package identifiers, installer identity, and signing identity are different.

## Project identity

| Platform | BaytBeam identity |
|---|---|
| Android | `com.baytbeam.app` |
| iOS | `com.baytbeam.app` |
| iOS Share Extension | `com.baytbeam.app.ShareExtension` |
| macOS | `com.baytbeam.app` |
| Linux | application ID `com.baytbeam.app`, package name `baytbeam`, executable `baytbeam_app` |
| Windows | executable `baytbeam_app.exe`, installer AppId `{B7D2A8E5-5F2D-4E76-9E36-BC7B7E5A2D11}`, MSIX helper identity `BaytBeam.App` |

Internal Dart and Rust package names such as `localsend_app` and `rust_lib_localsend_app` are intentionally retained. They are implementation/FFI names, not the platform installation identity, and changing them would create unnecessary compatibility risk.

## Android signing

The project maintainer keystore is generated locally as `secrets/baytbeam-release.jks` and is ignored by Git. It must never be committed or uploaded as a public artifact. Every Android version intended to update the same installed BaytBeam app must be signed with this same keystore and the `baytbeam` alias.

The current local certificate fingerprint is:

```text
SHA-256: AD:71:10:DF:28:50:75:C0:63:4B:9A:60:07:D2:C8:DD:89:F4:C4:9E:22:11:1D:A7:1E:DE:AC:5A:E6:22:1F:FE
```

CI is configured to use these repository secrets when they are available:

```text
BAYTBEAM_ANDROID_KEYSTORE_BASE64
BAYTBEAM_ANDROID_STORE_PASSWORD
BAYTBEAM_ANDROID_KEY_PASSWORD
```

If the secrets are absent, CI can create a disposable test key so that a verification build can still run. Such an APK is not suitable for updating a previous maintainer-signed installation.

## Windows signing

The local maintainer certificate is stored publicly as `support/signing/baytbeam-code-signing.cer`. The private key and PFX are stored only in the ignored `secrets/` directory. The certificate subject and the Windows MSIX Publisher are both:

```text
CN=BaytBeam Project, O=BaytBeam Project, C=EG
```

The certificate SHA-256 fingerprint is:

```text
41:54:6D:FF:C9:A8:10:16:F7:27:BC:FA:45:AA:95:B8:45:2D:52:21:50:30:30:CD:FD:BA:2A:D5:71:04:C0:52
```

CI is configured to use these repository secrets when they are available:

```text
BAYTBEAM_WINDOWS_PFX_BASE64
BAYTBEAM_WINDOWS_PFX_PASSWORD
```

This is a self-signed certificate. It identifies the BaytBeam publisher and enables consistent signatures across versions, but Windows SmartScreen may still show a warning until the certificate is trusted locally or the executable is signed with a publicly trusted commercial certificate. The public `.cer` should be installed only when the user trusts the downloaded release and understands that it changes local certificate trust.

## Apple signing

The iOS and macOS bundle identifiers are already separated from official LocalSend. Device-installable and notarized Apple builds still require the maintainer's Apple Developer certificates, provisioning profiles, and team ID. The public CI workflow therefore keeps Apple artifacts unsigned unless those credentials are supplied through a separate private signing setup.

## License and attribution

The source remains under the Apache License 2.0 retained from the upstream-compatible codebase. The `NOTICE` file explains that BaytBeam is not an official LocalSend release and is not affiliated with the LocalSend project. Upstream copyright, attribution, and license notices must remain in derivative files.
