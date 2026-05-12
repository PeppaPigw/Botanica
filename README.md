# Botanica

Premium offline-first plant care app for iOS & Android. Calm, beautiful, and thoughtfully designed.

## Features

- **Garden** — Your plant collection with a premium “Today” card, room filtering, batch actions, and smart sorting
- **Tasks** — Swipe-to-complete with haptic feedback, undo, snooze (1h/3h/tomorrow/weekend), and skip
- **Plant Detail** — Hero cover photo, care tab with explainable rules, photo journal, growth comparison slider
- **Discover** — 300+ plant library with recommendations, trending tags, favorites, and smart search
- **Daily Flower** — 7 culture modes (Zodiac, Tarot, Almanac, Omikuji, Runes, Ogham, Just Flower) with unique reveal interactions
- **Calendar** — Month grid with care history dots, day agenda, streak tracking
- **Journal** — Photo + diary entries with mood chips, share cards, and match-framing overlay
- **Scan** — Plant identification with confidence UI, refinement flow, and offline fallback
- **Profile** — Language, units, belief mode, storage health, garden wellness

## Design

- Editorial typography (Fraunces + Plus Jakarta Sans)
- Glass morphism with semantic tiers (primary/secondary/subtle)
- Weather-adaptive mood theme (Open-Meteo)
- Tokenized motion system with reduce-motion support
- Dark mode with validated contrast
- RTL support (Arabic)

## Tech Stack

- Flutter 3.24+ (Material 3)
- `flutter_riverpod` — state management
- `go_router` — declarative routing
- `hive` / `hive_flutter` — offline-first local storage
- `flutter_animate` — micro-motion & entrance animations
- `dynamic_color` — Material You support
- `google_fonts` — editorial font pairing
- `flutter_slidable` — swipe actions
- `geolocator` + Open-Meteo — weather-adapted care
- `flutter_local_notifications` — DST-safe reminders
- `camera` + `image_picker` — journal & scan

## Localization

4 locales: **English**, **Chinese (中文)**, **Spanish (Español)**, **Arabic (العربية)**

```bash
flutter gen-l10n
```

ARB files: `lib/l10n/` | Generated: `lib/gen/l10n/`

## Run

```bash
flutter pub get
flutter gen-l10n
flutter run
```

## Build

```bash
# iOS
flutter build ios --release

# Android (signed AAB)
flutter build appbundle --release
```

## Test

```bash
flutter analyze
flutter test
```

## AI Support

Optional AI insights via an OpenAI-compatible proxy (no API keys embedded in the binary). Users opt in via Profile. See `server/ai_proxy/` for proxy setup.

## License

See [LICENSE](LICENSE)
