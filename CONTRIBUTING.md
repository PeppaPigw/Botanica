# Contributing

Thanks for your interest in contributing to Botanica!

## Development setup

### Prerequisites

- Flutter SDK: **stable** (CI currently uses **Flutter 3.24.3**)
- A recent Xcode (for iOS) and/or Android Studio (for Android)

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter gen-l10n
flutter run
```

## Quality gates (required)

Before opening a PR, run:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test --timeout 60s
```

CI enforces the same checks and also gates on a **release appbundle build**
(`flutter build appbundle --release`) and a secrets scan.

## Integration smoke (optional but recommended)

Integration tests require an emulator/simulator or an attached device.

```bash
# Runs unit tests + a quick integration smoke test by default.
make test-integration
```

If you don't have a simulator running yet:

```bash
flutter emulators --launch apple_ios_simulator
```

You can override the target device:

```bash
# Use a device id (preferred)
BOTANICA_DEVICE_ID="<device-id>" make test-integration

# Or use a device name / id prefix
BOTANICA_DEVICE="iPhone" make test-integration
```

## Secrets and credentials

Do **not** commit secrets to the repository. In particular, do not add or
commit files such as:

- `.env`
- `android/key.properties`
- Android keystores (`.jks`, `.keystore`)

Release signing is documented in `docs/release.md` and is designed to be driven
via CI secrets.
