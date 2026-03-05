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

Android builds use Gradle.

### Gradle network pitfalls (macOS / local env)

Some macOS setups configure a **system SOCKS proxy** (common with proxy apps).
Java/Gradle will automatically pick this up via JVM system properties
(`socksProxyHost` / `socksProxyPort`). If the proxy is unreachable or blocks
Gradle traffic, Gradle downloads can fail with:

- `javax.net.ssl.SSLHandshakeException: Remote host terminated the handshake`

Recommended (does not change global machine config): disable SOCKS proxy just
for the build command:

```bash
export JAVA_TOOL_OPTIONS="-DsocksProxyHost= -DsocksProxyPort="
```

This repo also configures Gradle to allow TLS 1.3 in `android/gradle.properties`.

If your machine has `~/.gradle/gradle.properties` pinned to TLS 1.2
(e.g. `systemProp.https.protocols=TLSv1.2`), Maven Central / Plugin Portal
downloads may fail during release builds.

Recommended (does not change global machine config): override TLS per build:

```bash
export GRADLE_OPTS="-Dhttps.protocols=TLSv1.3,TLSv1.2"
```

If you want to fully isolate from `~/.gradle/` (recommended for reproducible
builds), set a project-local Gradle user home (gitignored):

```bash
export GRADLE_USER_HOME="$PWD/.gradle-user-home"
```

If you recently changed TLS settings (or after a failure), restart the Gradle
daemon:

```bash
cd android && ./gradlew --stop
```

```bash
# Android APK
JAVA_TOOL_OPTIONS="-DsocksProxyHost= -DsocksProxyPort=" \
GRADLE_OPTS="-Dhttps.protocols=TLSv1.3,TLSv1.2" \
GRADLE_USER_HOME="$PWD/.gradle-user-home" \
flutter build apk --release

# Android App Bundle
JAVA_TOOL_OPTIONS="-DsocksProxyHost= -DsocksProxyPort=" \
GRADLE_OPTS="-Dhttps.protocols=TLSv1.3,TLSv1.2" \
GRADLE_USER_HOME="$PWD/.gradle-user-home" \
flutter build appbundle --release

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

Also supported (CI-friendly, non-project-specific):

```bash
export ANDROID_KEYSTORE_PATH="keystore/release.jks"
export ANDROID_KEYSTORE_PASSWORD="..."
export ANDROID_KEY_ALIAS="release"
export ANDROID_KEY_PASSWORD="..."
```

### Build

```bash
flutter build apk --release
flutter build appbundle --release
```

If release signing is not configured, the build will fall back to **debug
signing** (not Play Store uploadable) and log a clear warning.

To enforce publishable signing in CI/release pipelines, set:

```bash
BOTANICA_REQUIRE_RELEASE_SIGNING=true
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
