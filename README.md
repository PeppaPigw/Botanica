# Botanica

Premium plant care for iOS + Android — offline-first, calm, and beautifully designed.

This repository follows `TaskBook.md` and ships an MVP UI + architecture for:

- **Garden**: plant collection + “Today” tasks card
- **Tasks**: swipe-to-complete + next scheduling
- **Plant Detail**: parallax hero + “pull-to-water” (Sliver stretch trigger)
- **Discover**: curated library + guides (search + chips)
- **Daily Flower**: deterministic daily card (locale + belief mode)
- **Profile**: language / units / mode + credits

## Tech stack (open-source)

- Flutter (Material 3)
- `flutter_riverpod` (state)
- `go_router` (navigation)
- `hive` / `hive_flutter` (offline local DB, JSON Maps)
- `flutter_animate` (micro-motion)
- `dynamic_color` (Material You / dynamic schemes when available)
- `google_fonts` (Fraunces + Plus Jakarta Sans pairing)
- `flutter_slidable` (refined swipe actions)
- `geolocator` (location)
- Open‑Meteo (free weather API)

Credits + references are also shown in-app: **Profile → Credits**.

## Localization

`gen_l10n` is configured via `l10n.yaml`.

- ARB files: `lib/l10n/`
- Generated output: `lib/gen/l10n/`
- Currently included locales: **en**, **zh**, **es**, **ar** (RTL included)

## Assets (temporary placeholders)

The UI intentionally uses **placeholder PNGs** while you collect final imagery.
Right now they are flat white so you can replace them later by dropping in the
real assets with the same filenames (no code changes needed):

- Species cards: `assets/placeholders/species/*.png` (including `unknown.png`)
- Daily Flower thumbnails: `assets/placeholders/daily_flowers/*.png`
- Tarot deck: `assets/placeholders/tarot/*.png` (including `unknown.png`)
- Onboarding texture: `assets/placeholders/onboarding/onboarding_texture.png`
- Share cards: `assets/placeholders/share/*.png`

Replace with real photos/illustrations later without touching layout code.

## Run

```bash
flutter pub get
flutter gen-l10n
flutter run
```

## Release

See `docs/release.md` for:

- Reproducible release build commands
- Android signing (`key.properties` / CI env vars)
- iOS bundle id + signing notes

## Weather (Open‑Meteo)

Environment snapshots use Open‑Meteo’s free API: `https://open-meteo.com/en/docs`.

Example:

```bash
curl "https://api.open-meteo.com/v1/forecast?latitude=45.52&longitude=-122.68&current=temperature_2m,relative_humidity_2m,weather_code&timezone=America/Los_Angeles"
```

## Quality checks

```bash
flutter analyze
flutter test --timeout 60s
```

## Running tests

Unit tests:

```bash
make test
```

Integration tests (requires an emulator/simulator or attached device):

```bash
# Runs unit tests + a quick integration smoke test by default.
make test-integration
```

The script auto-selects an available iOS simulator (preferred) or Android
emulator. If you don't have one running yet:

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

By default, `make test-integration` runs a quick smoke test:

- `integration_test/app_smoke_test.dart`

To run the full integration suite:

```bash
BOTANICA_INTEGRATION_ALL=true make test-integration
```

## AI support (proxy-first)

Botanica’s Flutter app is designed to **never embed long‑lived API keys** in the
`.ipa` / `.apk`. Instead, the app calls an OpenAI‑compatible **proxy** you host,
and the proxy attaches the upstream API key server‑side.

The AI layer sits behind `BotanicaAiService` and uses OpenAI‑compatible chat
completions while enforcing “reply in the user’s locale language”.
Responses are cached in Hive with a short TTL to avoid repeated requests.

### Configuration (safe)

1. Deploy/run the proxy in `server/ai_proxy/` (see `server/ai_proxy/README.md`).

2. Point Botanica at the proxy:

```bash
flutter run \
  --dart-define=BOTANICA_AI_BASE_URL=http://localhost:8787 \
  --dart-define=BOTANICA_AI_AUTH=none \
  --dart-define=BOTANICA_AI_MODEL=gpt-4o-mini \
  --dart-define=BOTANICA_PROXY_TOKEN=dev-token
```

Users can opt in/out via **Profile → AI insights**. There is no API key entry UI.

Notes:

- **iOS Simulator**: `http://localhost:8787` usually works.
- **Android Emulator**: use `http://10.0.2.2:8787`.
- **Real device**: use your Mac’s LAN IP (e.g. `http://192.168.1.23:8787`).
