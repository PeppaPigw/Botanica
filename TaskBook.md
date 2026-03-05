# Flutter Plant Care App — Botanica

## 0) Scope and assumptions

**Platforms:** iOS + Android (Flutter, Material 3).
**Offline-first:** Core features usable without login; optional cloud sync later.
**Core modules:** Plant records, care plans + reminders, growth photo journal, plant identification by photo, environment-aware recommendations, “Daily Flower” (zodiac/tarot/local belief systems), multilingual UI.

---

## 1) Product goals

### Primary goals

1. Make it effortless to **track plants** and **never miss care** (watering/fertilizing/repotting/misting).
2. Help users **learn** by showing *why* recommendations change (weather/humidity/location).
3. Build a **premium, calming UI** that feels “designed” (typography, motion, depth, micro-interactions).
4. Enable “magic moments”: **scan plant → identify → add → get a tailored care plan**.

### Success metrics (measurable)

* Reminder adherence: % of tasks completed within 24h of reminder.
* Activation: % of users adding ≥1 plant + enabling reminders.
* Identification success: % scans resulting in a confident match saved to Garden.
* Retention: D7/D30 returning users (especially after first reminders).

---

## 2) User personas and key needs

1. **Busy indoor plant owner**: wants simple reminders + quick actions (“watered” in one tap).
2. **Beginner learner**: wants clear, friendly explanations + “do this today” guidance.
3. **Collector / hobbyist**: wants rich plant profiles, photo timeline, seasonal adjustments.
4. **Spiritual / lifestyle user**: wants “Daily Flower” ritual (meaning, care, appreciation prompt).

---

## 3) Core user journeys (happy paths)

### A) Add first plant in <60 seconds

Onboarding → “Scan” → photo → identify suggestions → pick result → auto-fill care plan → set location + reminders → saved to Garden.

### B) Daily care loop (the “heartbeat”)

Open app → **Today card** shows tasks → swipe to complete (water/fertilize) → celebratory micro-animation → optional photo update.

### C) Growth journaling

Plant detail → “Add photo” → match previous framing (ghost overlay) → timeline compare slider → auto-highlight changes.

### D) Daily Flower ritual

Daily tab → reveal card (zodiac/tarot/local) → flower story + symbolism → 30-second appreciation exercise → optional share/save.

---

## 4) Functional requirements

## 4.1 Plant records (Garden)

**Features**

* Add plant (manual / from library / scan identify).
* Plant profile: nickname, species, pot size, soil type, sunlight level, room, notes, toxicity warning, purchase date.
* Batch actions: “Water all plants in Room”, “Snooze reminders”.

**Data captured**

* `Plant`: id, nickname, speciesId, photoCover, roomId, createdAt
* `PlantMeta`: potDiameter, soilType, lightLevel, lastRepotDate, lastFertilizeDate, etc.

**Acceptance criteria**

* Plant list loads instantly from local DB.
* Editing plant never loses history (logs preserved).

---

## 4.2 Care plan engine (habits + instructions)

A plant has **Care Rules** (species defaults) + **Overrides** (user/environment adjustments) → produces **Tasks**.

**Task types**

* Water, fertilize, mist, rotate, prune, repot, check pests, wipe leaves, sunlight adjustment.

**Rules model**

* Base interval (e.g., water every 7 days) + constraints:

  * “Only when top 2cm soil dry” (rule text)
  * seasonal modifier
  * humidity/temperature modifier
  * pot size & soil type modifier

**UI requirement**

* Always show: **“Next watering in X days” + “Why”** (expandable explanation).

---

## 4.3 Reminders and scheduling

Use local notification scheduling:

* Option A: `flutter_local_notifications` (cross-platform scheduled local notifications). ([Dart packages][1])
* Option B: `awesome_notifications` (richer layouts, images/buttons). ([Dart packages][2])

**Reminder logic**

* Each task has:

  * dueAt (timestamp)
  * reminderAt (user preference: morning/evening or exact time)
  * snooze rules
* If user marks “done” late, next dueAt shifts from completion time (configurable).

**Edge cases**

* Timezone change: rebase schedules to local timezone.
* DST shift: avoid duplicate notifications; use stable IDs per task instance.

---

## 4.4 Growth photo journal

**Features**

* Capture photo (camera) or select from gallery.
* “Match framing” overlay: show last photo as translucent guide.
* Timeline view: vertical feed with date + notes.
* Compare mode: slider to compare two photos.

**Storage**

* Save local compressed image + metadata (hash, timestamp, plantId, optional tags).
* Optional cloud backup later.

---

## 4.5 Plant identification by photo

Two recommended implementations:

### Option A (deterministic taxonomy): Plant.id (Kindwise)

* Send image → returns suggestions + confidence + plant info. ([Kindwise][3])
  **Pros:** purpose-built for plant ID; consistent results.
  **Cons:** API cost; network dependency.

### Option B (flexible reasoning): Gemini Vision

* Use Gemini image understanding for captioning/classification and structured output (JSON schema). ([Google AI for Developers][4])
  **Pros:** can generate care explanations, detect context (“leaf spots”, “overwatering signs”).
  **Cons:** needs careful prompting + verification for scientific accuracy.

**Recommended approach (hybrid)**

* Primary: Plant.id for species candidate list.
* Secondary: Gemini to:

  * summarize key traits,
  * generate beginner-friendly care checklist,
  * propose “confidence questions” (“Are leaves glossy?”) to disambiguate.

**Scan flow requirements**

1. Camera opens with a clean scan frame + tips.
2. After capture:

   * show preview
   * run upload + progress
3. Results page:

   * top 3 candidates with confidence bars
   * “Not sure?” → ask 2–3 quick questions (chips) to refine
4. “Add to Garden” → auto-create plant profile + care plan.

---

## 4.6 Environment-aware recommendations (location/climate/humidity)

### Data inputs

* Location permission + GPS via `geolocator`. ([Dart packages][5])
* Weather & humidity from OpenWeatherMap:

  * Current weather includes humidity/temperature. ([openweathermap.org][6])
  * One Call API for forecast & richer signals. ([openweathermap.org][7])

### Environment model

Create daily `EnvironmentSnapshot`:

* `tempC`, `humidity`, `cloudiness`, `rain`, `wind`, `season`, `dayLength` (optional), `indoorAssumption` (default true)
* Derived metric: **Dryness Index** (0–1)

  * Example: higher temp + lower humidity → higher dryness → shorter watering interval.

### Recommendation adjustment rules (explainable)

For watering interval `baseDays`:

* `adjustedDays = baseDays * f(humidity,temp,season,potSize,soilType)`
* Example multipliers (tunable):

  * humidity < 35% → ×0.75
  * humidity 35–60% → ×1.0
  * humidity > 70% → ×1.15
  * temp > 28°C → ×0.85
  * winter season → ×1.20
* Always show “Why changed?” with bullet reasons (no black box).

**UX requirement**

* Provide a toggle: **“Indoor / Balcony / Outdoor”** per plant; outdoor uses forecast weight more heavily.

---

## 4.7 Daily Flower (zodiac/tarot/local belief systems)

### Content requirements per “Daily Flower”

* Name (localized)
* Meaning keywords (3–6)
* Symbolism paragraph
* Care basics (light, water, temperature, pet safety)
* “How to appreciate today” (1 small ritual: scent, color observation, journaling prompt)
* Cultural variant mappings (by country/locale)

### Belief system selector

On first entry (or via Settings):

* Western zodiac
* Chinese zodiac
* Tarot draw
* “Local traditions” (per locale pack)
* “Just give me a flower” (non-spiritual mode)

### Daily generation logic

* Seed = date + user locale + (optional) chosen sign/card
* Deterministic output per day (so users can share the same flower that day)
* Offline fallback: packaged JSON database

---

## 4.8 Multilingual support

Use Flutter localization workflow (ARB + generated delegates). ([docs.flutter.dev][8])
Requirements:

* All strings localized (including plant care rule explanations).
* Locale-aware units: °C/°F, mm/inches, weekday formats.
* RTL support (layout mirroring test plan).

---

## 5) Information architecture & navigation

### Primary navigation (bottom tabs)

1. **Garden** — plant collection + today tasks
2. **Discover** — plant library, guides, search
3. **Daily** — Daily Flower ritual
4. **Profile** — settings, language, permissions, backup

**Global FAB (contextual)**

* In Garden: “Add Plant”
* In Plant Detail: “Add Photo”
* In Tasks list: “Add custom task”

---

## 6) Design system (premium botanical)

### Visual principles

* Calm, airy whitespace
* Natural gradients + subtle texture
* Soft depth (blur glass layers, gentle shadows)
* Micro-motion: everything responds, nothing distracts

### Color strategy

* Material 3 + optional dynamic color (`dynamic_color`) for device-based schemes. ([Dart packages][9])
* Brand seed color: deep leaf green (use as seed, not flat fill everywhere).
* Surfaces:

  * Light: warm off-white + pale green tint
  * Dark: near-black green + muted highlights
* Semantic:

  * Water = cool accent
  * Sun = warm accent
  * Warning/pests = restrained amber/red (avoid harsh)

### Typography (Google Fonts)

Use `google_fonts` for consistent cross-platform typography. ([Dart packages][10])
Recommended pairing (premium/editorial):

* Headlines: **Fraunces** (soft serif, botanical editorial feel)
* Body/UI: **Plus Jakarta Sans** or **Inter** (clean, high legibility)
  Type scale example:
* H1 34 / w600 (Fraunces)
* H2 24 / w600
* Body 16 / w450
* Caption 12 / w450 + increased letter spacing

### Motion & micro-interactions

Use `flutter_animate` for refined transitions (fade/slide/blur/scale combos). ([Dart packages][11])
Glass UI layers: `glassmorphism` (blurred cards over plant photography). ([Dart packages][12])

Motion rules:

* Default page enter: fade + slight upward slide (120–180ms)
* Completion feedback: tiny scale “pop” + sparkle particle (optional Lottie)
* Avoid bouncy overshoots unless celebratory

---

## 7) Screen-by-screen UI + interaction specification

## 7.1 Splash

**UI**

* Fullscreen plant macro photo + brand mark (center)
* Subtle breathing blur / gradient shift

**Logic**

* Initialize DB, load theme, locale, notification permission state.

---

## 7.2 Onboarding (3 pages)

**Page 1:** “Your Garden, beautifully organized” (collection + photo timeline)
**Page 2:** “Smart care, tuned to your environment” (location/climate)
**Page 3:** “Daily Flower ritual” (meaning + appreciation)

**Interactions**

* Horizontal swipe with parallax imagery
* CTA: “Start” → Permissions screen

---

## 7.3 Permissions (progressive disclosure)

**Cards**

1. Notifications: “So you never miss watering”
2. Location: “So care adapts to climate”
3. Camera/Photos: “For growth journal & plant scan”

**Rules**

* Ask only when feature is first used (unless user chooses “enable all now”).

---

## 7.4 Garden (tab)

**Top area**

* “Today” glass card:

  * next task count
  * weather snapshot chip (temp/humidity)
  * quick actions: “Watered”, “Snooze”, “Add plant”

**Plant list**

* Staggered cards:

  * cover photo
  * nickname + species
  * next watering countdown ring
  * status badge (OK / Thirsty / Check)

**Gestures**

* Swipe plant card:

  * right: mark watering done
  * left: open quick menu (edit, add photo, move room)
* Long-press: reorder / multi-select

**Empty state**

* Beautiful illustration + “Scan your first plant” primary CTA.

---

## 7.5 Add Plant (modal flow)

Entry points: FAB, empty state, Discover → “Add”.

**Step 1: Choose method**

* Scan (primary)
* From library
* Manual entry

**Step 2A: Scan**

* camera + framing guide
* tips carousel (“capture leaf + whole plant”)

**Step 2B: Library**

* search + filters (light level, pet-safe, difficulty)

**Step 3: Confirm**

* nickname
* location (room)
* environment mode (indoor/outdoor)
* reminder time preference (morning/evening/custom)

---

## 7.6 Plant Detail (core “home” per plant)

**Header**

* Hero image (parallax)
* nickname + species
* “health” hint chip (optional)

**Sections (sticky segmented control)**

1. **Overview**

   * next tasks timeline
   * environment impact (“Humidity low → water sooner”)
2. **Care**

   * light / water / soil / temp cards
   * “Why” explanations (expandable)
3. **Journal**

   * photo timeline
   * compare slider
4. **Logs**

   * list of actions (watered, fertilized, notes)

**Primary actions**

* Water now
* Add photo
* Add note

**Micro-interaction**

* “Pull-to-water”: pull down on plant photo → fills watering meter → release to mark done (gentle haptic).

---

## 7.7 Tasks (within Garden via “Today”)

**Views**

* Today / Upcoming / Overdue tabs
* Calendar view toggle (month + agenda)

**Task item**

* Plant avatar + task icon
* due time
* swipe actions: done / snooze / reschedule

**Rules**

* Completing a task instantly recomputes next due date (with environment adjustment).

---

## 7.8 Discover (tab)

**Content**

* Plant library (curated)
* Guides: watering basics, soil types, pest checklists
* Search (by name, difficulty, pet-safe)

**Design pattern inspiration**

* Card-based discovery similar to high-end plant apps and modern templates (clean imagery + rounded cards).

---

## 7.9 Daily (tab): Daily Flower

**Top**

* Belief mode selector (chip row)
* “Reveal” animated card (tarot flip / zodiac shimmer)

**Body**

* Flower name + meaning tags
* “Symbolism story”
* “Care today” (practical)
* “Appreciation ritual” (30–60s)
* Save/share buttons

**Animation**

* Card reveal: blur → sharpen + gentle scale
* Background: slow gradient drift + floating petal particles (subtle).

---

## 7.10 Profile / Settings

**Sections**

* Language
* Units (°C/°F)
* Notifications (time windows, quiet hours)
* Location (auto/manual city)
* Privacy (photo upload: on/off; clear data)
* Backup (later: cloud sync)

---

## 8) Technical architecture (Flutter)

### Recommended open-source baselines to fork/reference

* **MDeLuise/plant-it** for tracking + notifications + images, strong foundation. ([GitHub][13])
* **SevenSquare-Tech/plant-care-app** for exploration/identification/reminders patterns. ([GitHub][14])
* **abuanwar072/Plant-App-Flutter-UI** for polished card layouts + transitions. ([GitHub][15])

### State management

* **Riverpod** for scalable reactive state + async handling. ([Dart packages][16])

### Local storage

* **Hive** for lightweight offline DB (fast key-value, great for offline-first). ([Dart packages][17])
  (If you need complex queries: add SQLite/Drift later; keep MVP simple.)

### Networking

* Dio + caching layer (ETag/TTL) for weather + identification.

### Suggested module layout

* `features/garden`, `features/plant_detail`, `features/tasks`, `features/discover`, `features/daily_flower`
* `data/` (repositories, DTOs), `domain/` (entities/usecases), `ui/` (screens/widgets)

---

## 9) Key data models (minimal but extensible)

* `UserSettings`: locale, units, reminderPrefs, beliefMode, quietHours
* `Plant`: id, nickname, speciesId, roomId, coverPhotoId, createdAt
* `Species`: id, scientificName, commonNamesByLocale, careDefaults, toxicity, tags
* `CareRuleSet`: baseIntervals + conditionalModifiers
* `TaskInstance`: id, plantId, type, dueAt, reminderAt, status, createdAt
* `CareLog`: id, plantId, type, timestamp, note, linkedPhotoId?
* `PhotoEntry`: id, plantId, filePath, createdAt, note, hash
* `EnvironmentSnapshot`: timestamp, lat/lon, temp, humidity, weatherCode
* `DailyFlowerEntry`: date, locale, beliefMode, key, contentPayload

---

## 10) Reference stack (APIs/packages) — what to use where

* **Plant identification:** Plant.id (Kindwise) docs + examples. ([Kindwise][3])
* **AI vision fallback / explanations:** Gemini image understanding. ([Google AI for Developers][4])
* **Weather/humidity:** OpenWeather current + One Call. ([openweathermap.org][6])
* **Location:** geolocator. ([Dart packages][5])
* **Animations:** flutter_animate. ([Dart packages][11])
* **Glass UI:** glassmorphism. ([GitHub][18])
* **Fonts:** google_fonts. ([Dart packages][10])
* **Localization:** Flutter i18n (gen_l10n). ([docs.flutter.dev][8])

---

## Curated links (copy/paste)

```text
GitHub baselines:
https://github.com/MDeLuise/plant-it
https://github.com/SevenSquare-Tech/plant-care-app
https://github.com/abuanwar072/Plant-App-Flutter-UI

Design/UI inspiration:
https://dribbble.com/shots/18619889-Plant-Care-App-UI-Design
https://www.imore.com/apps/planta-is-a-pricey-but-detailed-houseplant-care-iphone-app-for-indoor-gardeners

Flutter packages:
https://pub.dev/packages/flutter_animate
https://pub.dev/packages/glassmorphism
https://pub.dev/packages/google_fonts
https://pub.dev/packages/flutter_local_notifications
https://pub.dev/packages/awesome_notifications
https://pub.dev/packages/geolocator
https://pub.dev/packages/dynamic_color
https://pub.dev/packages/flutter_riverpod
https://pub.dev/packages/hive

APIs:
https://www.kindwise.com/plant-id
https://documenter.getpostman.com/view/24599534/2s93z5A4v2
https://openweathermap.org/current
https://openweathermap.org/api/one-call-3
https://ai.google.dev/gemini-api/docs/image-understanding
https://docs.flutter.dev/ui/internationalization
```

[1]: https://pub.dev/packages/flutter_local_notifications?utm_source=chatgpt.com "flutter_local_notifications | Flutter package - Pub"
[2]: https://pub.dev/packages/awesome_notifications?utm_source=chatgpt.com "awesome_notifications | Flutter package - Pub"
[3]: https://www.kindwise.com/plant-id?utm_source=chatgpt.com "plant.id AI Plant Identification API by kindwise"
[4]: https://ai.google.dev/gemini-api/docs/image-understanding?hl=zh-cn&utm_source=chatgpt.com "图片理解 - Gemini API | Google AI for Developers"
[5]: https://pub.dev/packages/geolocator?utm_source=chatgpt.com "geolocator | Flutter package - Pub"
[6]: https://openweathermap.org/current?utm_source=chatgpt.com "Current weather data - OpenWeatherMap"
[7]: https://openweathermap.org/api/one-call-3?utm_source=chatgpt.com "One Call API 3.0 - OpenWeatherMap"
[8]: https://docs.flutter.dev/ui/internationalization?utm_source=chatgpt.com "Internationalizing Flutter apps"
[9]: https://pub.dev/packages/dynamic_color?utm_source=chatgpt.com "dynamic_color | Flutter package - Pub"
[10]: https://pub.dev/packages/google_fonts?utm_source=chatgpt.com "google_fonts | Flutter package - Pub"
[11]: https://pub.dev/packages/flutter_animate?utm_source=chatgpt.com "flutter_animate | Flutter package - Pub"
[12]: https://pub.dev/documentation/glassmorphism/latest/?utm_source=chatgpt.com "glassmorphism - Dart API docs - Pub"
[13]: https://github.com/MDeLuise/plant-it?utm_source=chatgpt.com "MDeLuise/plant-it: Open source Android gardening ... - GitHub"
[14]: https://github.com/SevenSquare-Tech/plant-care-app?utm_source=chatgpt.com "GitHub - SevenSquare-Tech/plant-care-app"
[15]: https://github.com/abuanwar072/Plant-App-Flutter-UI?utm_source=chatgpt.com "GitHub - abuanwar072/Plant-App-Flutter-UI"
[16]: https://pub.dev/packages/flutter_riverpod?utm_source=chatgpt.com "flutter_riverpod | Flutter package - Pub"
[17]: https://pub.dev/documentation/hive/latest/?utm_source=chatgpt.com "hive - Dart API docs - Pub"
[18]: https://github.com/RitickSaha/glassmorphism?utm_source=chatgpt.com "GitHub - RitickSaha/glassmorphism: Glassmorphic UI Package For Flutter ..."
