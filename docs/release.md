# Release Build & Signing Runbook

This document describes how to produce **release artifacts** and configure
**publishable signing** without committing secrets.

## Release artifacts (paths)

Android:

- APK: `build/app/outputs/flutter-apk/app-release.apk`
- App Bundle (Play Store): `build/app/outputs/bundle/release/app-release.aab`

iOS:

- Unsigned app (for manual signing later): `build/ios/iphoneos/Runner.app`

## Release builds (commands)

> If your machine has `~/.gradle/gradle.properties` pinned to TLS 1.2
> (e.g. `systemProp.https.protocols=TLSv1.2`), Gradle may fail downloading
> dependencies from Maven Central / Plugin Portal. Prefer using `GRADLE_OPTS`
> to override per-command (does not change global machine config).

```bash
# Android APK
GRADLE_OPTS="-Dhttps.protocols=TLSv1.3,TLSv1.2" flutter build apk --release

# Android App Bundle
GRADLE_OPTS="-Dhttps.protocols=TLSv1.3,TLSv1.2" flutter build appbundle --release

# iOS (unsigned)
flutter build ios --release --no-codesign
```

## Android signing (publishable)

### Application ID

Current `applicationId` is `com.botanica.botanica` in:

- `android/app/build.gradle`

### Create a keystore (local)

Choose a location **outside the repo** or under `android/` (gitignored).

Example (creates `android/keystore/release.jks`):

```bash
mkdir -p android/keystore
keytool -genkeypair -v \
  -keystore android/keystore/release.jks \
  -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias release
```

### Configure `android/key.properties` (not committed)

Create `android/key.properties` (this file is ignored by git):

```properties
storeFile=keystore/release.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=release
keyPassword=YOUR_KEY_PASSWORD
```

Alternative: provide the same values via environment variables:

```bash
export BOTANICA_ANDROID_KEYSTORE_PATH="keystore/release.jks"
export BOTANICA_ANDROID_KEYSTORE_PASSWORD="..."
export BOTANICA_ANDROID_KEY_ALIAS="release"
export BOTANICA_ANDROID_KEY_PASSWORD="..."
```

### Build

```bash
GRADLE_OPTS="-Dhttps.protocols=TLSv1.3,TLSv1.2" flutter build apk --release
GRADLE_OPTS="-Dhttps.protocols=TLSv1.3,TLSv1.2" flutter build appbundle --release
```

If release signing is not configured, the build will fail with a clear error.

For **local-only** builds that explicitly allow debug signing:

```bash
BOTANICA_ALLOW_DEBUG_SIGNING=true flutter build apk --release
```

### CI injection (GitHub Actions example)

Store secrets in GitHub Actions:

- `ANDROID_KEYSTORE_BASE64` (base64-encoded `.jks`)
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

At workflow runtime, write the keystore + `android/key.properties` to disk
(never commit them), then run `flutter build ... --release`.

## iOS signing (publishable)

### Bundle ID

Current iOS bundle ID: `com.botanica.botanica`

### Local signing (Xcode)

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the `Runner` target → **Signing & Capabilities**.
3. Set your **Team** and enable **Automatically manage signing**.
4. Ensure the bundle ID is correct for your Apple Developer account.

### CI signing

CI iOS signing typically uses:

- A distribution certificate + private key (`.p12`)
- A provisioning profile (`.mobileprovision`)

Common approaches include Fastlane (`match`) or manually installing certs and
profiles in the CI keychain before running `xcodebuild` / `flutter build ios`.

This repo supports reproducible, unsigned builds:

```bash
flutter build ios --release --no-codesign
```

## Security checklist

- Do **not** commit keystores, `android/key.properties`, `.p12`, provisioning
  profiles, or any API keys.
- Before pushing release-related changes, verify:

```bash
git status --porcelain
```

