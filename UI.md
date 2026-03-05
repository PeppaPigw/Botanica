# Botanica — UI & Interaction Design Report

This document describes the **visual language**, **interaction system**, and
screen-by-screen UX rules for Botanica, built to match the “Win on Beauty”
requirements in `optimizeUI.md` and the broader product spec in `TaskBook.md`.

Core rule: **UI / Design / Harmony first.**

---

## 1) Design North Star

Botanica should feel like:

- **Calm + premium** (editorial spacing, soft depth, restrained motion).
- **Deterministic + trustworthy** (daily ritual is consistent; care guidance is explainable).
- **Botanical, not “gamey”** (micro-feedback is subtle; no noisy particles or arcade haptics).
- **Offline-first by default** (no dead ends when the network is unavailable).

The app’s “signature moment” is **Daily Flower** (Template R), but the “daily
retention engine” is Garden → Tasks → Calendar (Template L).

---

## 2) Harmony System (Tokens → Templates → Component Kit)

The UI is intentionally system-driven:

1. **Tokens** are the only source of truth (spacing, radii, motion, typography).
2. **Templates** define layout archetypes (List / Detail / Ritual / Settings).
3. **Component Kit** is reused everywhere (glass tiers, nav pill, state cards, fields).

This prevents one-off “screen art” from drifting and keeps the whole product
visually coherent as features grow.

---

## 3) Visual Tokens (System Foundations)

### 3.1 Typography (Editorial + Accessible)

Font pairing (Google Fonts):

- **Fraunces**: used for **display / headline** moments (non-interactive).
- **Plus Jakarta Sans**: used for all **interactive UI** (labels, forms, buttons).

Rules:

- Prefer **semantic roles** over raw font sizes. Use:
  - `displayHero`, `headline`, `title`, `body`, `bodyMuted`, `label`, `chip`.
- Maintain readability under glass:
  - Favor weight and spacing over lowering opacity.
- Dynamic type / text scaling:
  - Layout should survive **1.2 → 1.6** text scale without clipping CTAs.

Implementation anchors:

- `lib/app/theme/botanica_semantics.dart`
- `lib/app/theme/botanica_text_styles.dart`
- `lib/core/widgets/screen_title.dart`

### 3.2 Spacing & Radii (Editorial Calm)

Baseline: a consistent scale (no “close enough” paddings).

- Page padding: `BotanicaTokens.pagePadding`
- Card padding: `BotanicaTokens.cardPadding` (or explicit but consistent 14–16)
- Radii: `radiusS/M/L/XL` (pills + rounded cards everywhere)

Implementation anchor:

- `lib/app/theme/botanica_tokens.dart`

### 3.2 Grid & Spacing Rhythm (“One Magazine” Rule)

Botanica’s calm premium look is mostly **spacing discipline**.
The app uses a small, consistent step scale and avoids per-screen “almost the
same” paddings.

Core spacing tokens:

- Screen outer padding: `BotanicaTokens.pagePadding` (horizontal 20)
- Section spacing: `BotanicaTokens.sectionPadding` (vertical 16)
- Card internal padding (14/16/18 rhythm):
  - `cardPaddingDense` = 14
  - `cardPadding` = 16
  - `cardPaddingRelaxed` = 18
- Spacing widgets (preferred over magic numbers):
  - `lib/core/widgets/botanica_gaps.dart` (`BotanicaGaps.vSm`, `hSm`, etc)

Rules:

- Tier 1 (“hero” / signature) is slightly roomier than Tier 2.
- Chips/tags must never reduce text readability by lowering opacity too far;
  prefer weight and spacing to create hierarchy.
- Tab screens must reserve bottom clearance using
  `BotanicaTokens.pagePaddingWithBottomNav(context)` so content never hides
  behind the nav pill.

Implementation anchors:

- `lib/app/theme/botanica_tokens.dart`
- `lib/core/widgets/botanica_section.dart`

### 3.3 Glass Tiers (One Glass Language)

Glass is **semantic**, not decorative. Every blurred surface must map to one tier:

- `GlassTier.primary`: hero / focal cards (Daily reveal, Garden “Today”)
- `GlassTier.secondary`: standard content cards (lists)
- `GlassTier.subtle`: chrome and low-emphasis surfaces (nav pill, helper notes)

Implementation anchors:

- `lib/app/theme/botanica_glass_theme.dart`
- `lib/core/widgets/glass_card.dart`

### 3.4 Color & Contrast

The color system is warm-calm with reliable contrast.

Rules:

- Glass surfaces must not reduce text contrast below usable levels.
- Accent usage is restrained: accents “punctuate,” they don’t flood.
- Dynamic color is optional; if enabled, it should **harmonize accents only**
  (base surfaces must stay Botanica-like).

Implementation anchors:

- `lib/app/theme/botanica_theme.dart`
- `lib/app/theme/botanica_semantics.dart`

### 3.5 Dynamic Weather Mood Theme (Location → Weather → Harmony)

Botanica adapts its *mood* to the user’s current weather without breaking the
core palette or introducing “theme chaos”.

Principles:

- Weather should change **atmosphere**, not identity.
- Changes must be **subtle**, **tokenized**, and **animated**.
- Offline or permission-blocked states must remain premium (fallback mood).

Pipeline:

1. **GPS** → fetch current environment (Open‑Meteo).
   - Hemisphere is derived automatically from latitude for seasonal care
     adjustments (no manual hemisphere toggle).
2. Map Open‑Meteo `weather_code` → `WeatherKind` buckets (clear/rain/snow…).
3. Compute a **Weather Mood** (tinted glow colors) blended into Botanica’s
   existing containers.
4. Apply mood primarily to the **botanical background glows** to keep UI
   contrast stable.

Implementation anchors:

- Weather mapping: `lib/core/environment/weather_code.dart`
- Mood extension: `lib/app/theme/botanica_weather_mood.dart`
- Background renderer: `lib/core/widgets/botanica_background.dart`
- Theme animation: `lib/app/botanica_app.dart`

---

## 4) Interaction System (Motion, Haptics, Feedback)

### 4.1 Motion Tokens

All motion uses tokenized durations:

- `motionFast` (~140ms): micro feedback
- `motionMedium` (~220ms): component transitions
- `motionSlow` (~360ms): ritual reveal / larger UI changes

Reduce Motion:

- Looping particles are disabled when system reduce-motion is enabled.
- Large transitions should simplify (no continuous loops).

Implementation anchors:

- `lib/app/theme/botanica_tokens.dart`
- `lib/core/utils/motion_preferences.dart`

### 4.2 Haptic Map

Haptics are punctuation, not noise:

- Selection tick: chips / threshold steps
- Primary press: CTA press
- Reveal climax: ritual completion moment

Implementation anchor:

- `lib/core/haptics/botanica_haptics.dart`

### 4.3 Premium States (Loading / Empty / Error / Offline / Blocked)

Every state is designed; no raw “blank page”.

Implementation anchor:

- `lib/core/widgets/botanica_state_card.dart`

Standard recipe (error):

- Icon: `Icons.cloud_off_rounded`
- Title/body: `stateLoadFailedTitle` / `stateLoadFailedBody`
- Action: `BotanicaButton(variant: outlined, icon: refresh, label: commonTryAgain)`

---

## 5) Component Kit (Reusable Building Blocks)

### 5.0 BotanicaScaffold (Global Layout Consistency)

Goals:

- Standardize the “transparent scaffold over botanical background” foundation.
- Keep a single background language with per-screen intensity control.
- Centralize scaffold defaults (`extendBody`, chrome transparency) so screens
  don’t reinvent layout decisions.

Implementation anchors:

- `lib/core/widgets/botanica_scaffold.dart`
- `lib/core/widgets/botanica_page_scaffold.dart`
- `lib/app/routing/app_shell.dart`

Related helpers:

- `BotanicaTokens.pagePaddingWithBottomNav(context)` for tab screens.

### 5.1 Bottom Navigation Pill

Goals:

- Label shown only for the active destination.
- Micro-motion: icon scale + label fade/slide.
- When there is enough horizontal space, the active destination expands to show
  the label inline (icon + label). On very narrow widths, the pill falls back
  to equal-width destinations with a stacked label for the active tab.
- Safe-area aware and consistent across iOS/Android gesture navigation.
- Constrained max width for large screens (keeps the pill “floating” and calm,
  avoids full-width heaviness on tablets).
- Floating actions (like Garden’s Add Plant) should respect the same centered
  grid on wide screens (FAB aligns to the nav pill content width, not the
  screen edge).

Destinations:

- Garden
- Calendar
- Discover
- Daily
- Profile

Implementation anchor:

- `lib/core/widgets/botanica_nav_pill.dart`
- `lib/app/routing/app_shell.dart`
- `lib/core/widgets/botanica_fab_location.dart`

Geometry + layout rules:

- Total pill height is `BotanicaTokens.navPillHeight` (68):
  - 56px core row height
  - + 6px padding on top/bottom inside the glass card
- The pill is centered and constrained to `maxWidth: 520` (tablet harmony).
- Bottom padding is safe-area aware, but intentionally “grounded” on iOS:
  - Android/others: `safeBottom + bottomExtra`
  - iOS: `min(safeBottom, navPillMaxSafeAreaInsetIOS) + bottomExtra`
  - Current token values (tuned for “float, but grounded”):
    - `navPillBottomInsetWithSafeArea = 0`
    - `navPillBottomInsetNoSafeArea = 4`
    - `navPillMaxSafeAreaInsetIOS = 6`

Position regression guard:

- A widget test asserts the nav pill doesn’t “float into the middle” on iOS by
  accidentally applying safe-area padding twice:
  - `test/widgets/app_shell_nav_pill_position_test.dart`

Interaction rules:

- Hit targets remain ≥48px even in compact layouts.
- Only the active destination shows a label (minimal, editorial).
- When the software keyboard is open, the pill hides (no mid-screen “floating
  tab bar”): focus stays on the active task, and the UI remains calm.
- Micro-motion is restrained:
  - selected icon subtle scale
  - label fade + slight slide
  - selection highlight “glides” (no bouncy spring)

Garden FAB harmony:

- Garden FAB aligns with the same centered grid as the nav pill on wide screens
  (tablet), instead of the far-right screen edge.
- FAB never overlaps the nav pill; it should hover above with a calm margin.

### 5.2 Buttons (One Button Language)

Goals:

- A single “Botanica button” look across screens (no per-screen style drift).
- Correct hierarchy by variant:
  - **Filled** for primary actions
  - **Outlined** for secondary actions
  - **Text** for tertiary actions
  - **Glass** only when the context is already glass-heavy (and it improves
    harmony, not decoration)
- Accessibility: semantics label is always present; disabled state reads as
  disabled.

Implementation anchors:

- `lib/core/widgets/botanica_button.dart`
- `lib/app/theme/botanica_theme.dart` (global radius + padding + typography)

Usage rule:

- Prefer `BotanicaButton(...)` over `FilledButton` / `OutlinedButton` /
  `TextButton` in feature screens so the visual language stays consistent.

### 5.3 Chips (Filters, Tags, Modes)

Goals:

- One chip anatomy across Garden/Tasks/Discover/Calendar filters.
- Clear selected state without “loud” colors.
- Stable density: chips should feel tappable but not chunky.

Implementation anchor:

- `lib/core/widgets/botanica_chip.dart`

Usage rule:

- Prefer `BotanicaChip(...)` for filter chips and quick actions.
- Use the optional `padding:` override for compact chips (e.g. weather chip).

### 5.4 Bottom Action Bar (Sticky Form CTA)

Goals:

- Keep the primary CTA reachable (one-hand grip) without forcing the user to
  scroll to the bottom of a long form.
- Keyboard-aware: CTA lifts above the keyboard, with a calm spacing gap.
- Visually consistent with the “floating glass” language (same geometry rhythm
  as the nav pill: 56px core + 8px padding).
- Safe-area aware, with the same “grounded iOS” rule as the nav pill (prevents
  CTAs hovering too high above the home indicator).

Implementation anchors:

- `lib/core/widgets/botanica_bottom_action_bar.dart`
- `lib/features/add_plant/add_plant_screen.dart` (example usage)

Usage rule:

- When used with `extendBody: true`, the form content must include bottom
  clearance: `BotanicaBottomActionBar.clearanceFor(context)`.

### 5.5 Search Field

Goals:

- Same search styling in Discover and Add Plant.
- Built-in clear affordance (no custom per screen).

Implementation anchor:

- `lib/core/widgets/botanica_search_field.dart`

### 5.6 Section Wrapper

Goals:

- A consistent “section title + optional action + spacing” language.

Implementation anchor:

- `lib/core/widgets/botanica_section.dart`

### 5.7 Share Cards (Designed Outputs)

Designed share outputs for:

- Plant photo journal entries
- Plant diary text entries
- Daily Flower ritual card

Implementation anchors:

- `lib/features/journal/photo_share_card_screen.dart`
- `lib/features/journal/diary_share_card_screen.dart`
- `lib/features/daily/daily_share_card_screen.dart`

Design rule:

- Daily share card optionally overlays the flower image (from `DailyFlowerContent.imagePath`)
  as a subtle watermark so the final export feels “crafted”, not templated.

### 5.8 Modal Sheets (One Sheet Language)

Goals:

- Consistent sheet rounding + clipping (same visual family everywhere).
- Calm density: use the same padding rhythm and “header row” anatomy.
- Keyboard-safe for text entry (bottom inset padding).

Standard recipe:

- `showDragHandle: true`
- `backgroundColor: scheme.surface.withValues(alpha: 0.98)`
- `clipBehavior: Clip.antiAlias`
- `shape: RoundedRectangleBorder(borderRadius: vertical(top: radiusXL))`
- `useRootNavigator: true` (so sheets slide over the entire AppShell, including
  the floating nav pill)

Implementation anchors (examples):

- `lib/features/profile/profile_screen.dart` (language/units/belief sheets)
- `lib/features/garden/garden_screen.dart` (edit plant sheet)
- `lib/features/plant_detail/plant_detail_screen.dart` (add photo / note sheets)
- `lib/features/discover/discover_screen.dart` (filter sheets)
- `lib/core/widgets/botanica_sheet.dart` (shared sheet styling helper)

Implementation rule (crash prevention):

- Any `TextEditingController` used inside a modal sheet must be **owned by the
  sheet widget** (State lifecycle) and disposed in `dispose()`.
- Avoid creating a controller outside `showBotanicaModalSheet(...)` and
  disposing it after the `await` returns; route transitions (e.g. date picker
  overlays) can otherwise leave a `TextField` rebuilding against a disposed
  controller.

---

## 6) Screen Templates (Apply Once, Improve Everywhere)

### Template L — Editorial List (Garden / Tasks / Discover)

Layout rules:

- Title row (consistent)
- Hero card (Tier 1)
- List cards (Tier 2)
- Tags/chips (Tier 3 / subtle)
- Empty and error states are premium cards (not plain text)

### Template D — Editorial Detail (Plant Detail / Species Detail)

Layout rules:

- Hero image with overlay + scrim rules for contrast
- “At a glance” first, then deeper content
- Sections read like an article (not a table dump)

### Template R — Ritual Immersive (Daily)

Layout rules:

- Minimal chrome
- One focal “reveal vessel”
- Post-reveal: editorial card (no chat bubbles)

### Template S — Settings & Forms (Profile / Add Plant / Permissions)

Layout rules:

- Clear grouping
- One primary action per page
- Progressive disclosure for permissions

---

## 7) Screen-by-Screen UX Specification

### 7.1 Splash

- Uses Botanica background language (low motion).
- No layout shifts; immediate perceived stability.

### 7.2 Onboarding

- 3 pages, each with one promise.
- CTA position never moves.
- Subtle scale/fade micro-motion; avoid jitter.

Placeholder imagery:

- `assets/placeholders/onboarding/onboarding_texture.png`

### 7.3 Permissions

Progressive disclosure cards:

- Notifications → “Never miss watering”
- Location → “Care adapts to climate”
- Camera/Photos → “Growth journal & plant scan”

Rules:

- Never hard-block exploration.
- Ask only when needed (or “enable all now”).

### 7.4 Garden (tab)

Top:

- “Today” hero card (Tier 1):
  - tasks due today
  - weather chip (temp/humidity)
  - quick actions: Tasks, Calendar, Add Plant

List:

- Plant cards (Tier 2) with:
  - nickname + species
  - habit snippet (1 line)
  - tags: light / difficulty / pet safety
  - watering status line

Gestures:

- Swipe right: water now (haptic + snackbar)
- Swipe left: edit / add photo

Floating action:

- Garden uses a single FAB (Add Plant) aligned to Botanica’s centered grid via
  `BotanicaAlignedEndFabLocation` (keeps harmony on tablets).

### 7.5 Tasks (within Garden)

- Segmented tabs: Today / Upcoming / Overdue
- Slidable actions: Done / Snooze
- Calendar entry point in AppBar

### 7.6 Calendar (tab)

- Month grid with subtle “history dots” (watering logs)
- Selected day agenda (tasks + logs)
- Quick “Watered” action, supports backfilling past days
- History filters (chips): All / Water / Fertilize / Mist

### 7.7 Discover (tab)

- Search (unified field)
- Filters (chips + bottom sheets)
- Two parallel catalogs:
  - **Curated** (from `species_seed.json`) for editorial quality and richer
    localization.
  - **Plant library** (from `plantsidea.json`) for breadth (300+ plants).
- Plant cards with:
  - image thumbnail
  - common name + scientific name
  - habit/history snippet

### 7.8 Species Detail

This screen supports both:

- A curated `Species` entry (`assets/data/species_seed.json`), and
- A library-only `PlantIdea` entry (`assets/data/plantsidea.json`).

Hero:

- 16:9 hero image with gradient scrim overlay.

Sections:

- Tags: difficulty / light / pet safety / water interval
- Habit (editorial body)
- History (editorial body)
- Resources (Wikipedia / YouTube / Baike / Bilibili / **GBIF** / care guide; copy-to-clipboard)
- Care at a glance (fact rows)

### 7.9 Add Plant

Method selection:

- Scan (primary)
- Library
- Manual entry

Confirm:

- Nickname, room
- Environment mode (indoor/balcony/outdoor)
- Reminder time preference
- Primary CTA is sticky: “Save to Garden” lives in a bottom action bar.

Library data source:

- The “Library” picker is powered by `assets/data/plantsidea.json` and supports
  300+ plants with stable `plant_id` identifiers.
- When a plant exists in both curated + library datasets, the app can use the
  curated entry for richer localization, but it always has the library entry
  as a fallback for resources and care defaults.

### 7.10 Plant Detail (per-plant “home”)

Hero:

- SliverAppBar stretch trigger: “pull-to-water”
- Hero cover prefers user photo when available; falls back to species image.

Tabs:

- Overview: next tasks + species card
- Care: explainable rules driven by `plantsidea.json` (watering/fertilizing,
  temperature/humidity/soil, pruning, pests/diseases, climate strategies)
- Journal: photos + compare + share cards
- Logs: history list

### 7.11 Journal (Photo + Diary)

Photo capture:

- Framing guide overlay
- Ghost overlay (previous photo) for matching angle

Diary:

- Text entry per plant
- Share as designed card (background + gradient + typography)

### 7.12 Daily (Ritual)

Gating rules:

- No mode selected → no daily entry; prompt to choose a mode in Profile.
- Western zodiac mode requires birth date or manual sign.
- Tarot mode requires drawing a card for the day.
- Almanac / Omikuji / Runes / Ogham / Just flower require a **personal key**
  (seed phrase or birth date) set in Profile.

Per-mode reveal interactions (each is unique):

- Western zodiac: **Slide to reveal** (haptic threshold ticks)
- Tarot: **Deal 4 → pick 1** (fan spread), then **flip reveal** (90° swap) on
  the selected card
- Almanac: **Stamp to reveal** (drag/tap stamp, imprint animation)
- Omikuji: **Pull to reveal** (fortune slip with label + haptic ticks)
- Runes: **Hold to reveal** (progress ring + rune glyph)
- Ogham: **Trace to reveal** (draw over stave guide)
- Just flower: **Tap to reveal** (a calm “orb” vessel; no busy motion)

Ritual pacing rules:

- Entry state is calm and clear: 1 gesture hint max (avoid tutorial overload).
- The reveal animation is “slow-intentional” (no random bounce).
- Afterglow state is editorial:
  - meaning + short care suggestion
  - optional share/save
  - flower thumbnail in the reveal card header (stable asset path; placeholder now)
  - optional AI note (only if enabled)
  - share card export includes the flower image as a subtle watermark (if available)

Mode info sheet:

- The mode card includes an info action that opens a calm “About Daily Flower”
  sheet (what the mode means + how the reveal works + “Change mode” CTA).

AI placement:

- AI is never a chat bubble.
- AI appears only as a quiet editorial “note” card **after** reveal and only when enabled.

---

## 8) AI Integration (Latent, Harmonious)

Principles:

- No assistant bubble, no popups, no “talking head”.
- AI appears only where it adds value without breaking harmony:
  - Daily post-reveal: a gentle reflection note
  - Plant detail: a calm “today’s insight” card (optional)

Implementation anchors:

- `lib/services/ai/ai_chat_client.dart` (OpenAI-compatible endpoint)
- `lib/services/ai/botanica_ai_prompts.dart` (system prompt enforces locale)
- `lib/services/ai/botanica_ai_service.dart` (caching + sanitization)
- `lib/services/ai/ai_providers.dart` (Riverpod providers)

---

## 9) Localization & Accessibility

Locales:

- `en`, `zh`, `es`, `ar` (RTL supported)

Accessibility checks:

- Text scale 1.2–1.6
- Reduce Motion support
- Contrast under glass (avoid “beautiful but foggy”)

---

## 10) Asset Strategy (Replaceable Placeholders)

Placeholder policy:

- Use stable asset paths so replacing art is “drop-in”.
- Keep placeholders inside `assets/placeholders/`.
- Prefer **one file per final asset name** (even if all placeholders are white)
  so you can replace images later without touching code or JSON.

Key folders:

- `assets/placeholders/species/`
- `assets/placeholders/daily_flowers/`
- `assets/placeholders/tarot/`
- `assets/placeholders/share/`
- `assets/placeholders/onboarding/`

Data → asset mapping rules:

- Species JSON (`assets/data/species_seed.json`) uses `imagePath` per species id.
- Plant knowledge base (`assets/data/plantsidea.json`) is the **full library**:
  - used for Discover’s “Plant library” section
  - used for Add Plant → Library picker
  - used as a fallback when a curated species entry is not available
- Image paths in `plantsidea.json` follow a stable convention:
  - `image_path: assets/placeholders/species/<plant_id>.png`
  - a placeholder exists for every `plant_id` so you can replace art later by
    filename only (no code/JSON edits required).
- Daily flower JSON (`assets/data/daily_flower_en.json`, `assets/data/daily_flower_zh.json`)
  uses `imagePath: assets/placeholders/daily_flowers/<key>.png`.
- Tarot cards use `assets/placeholders/tarot/<cardId>.png` (id-stable).

Helper tooling:

- `tools/sync_plantsidea_placeholders.py` keeps `plantsidea.json` image paths and
  placeholder PNGs aligned (safe to run repeatedly).

---

## 11) Reference Board (Open-source + Design Apps)

### 11.1 Flutter / GitHub references (used or pattern inspiration)

- Flutter samples: `flutter/samples` — https://github.com/flutter/samples
- Flutter framework + Material 3: https://github.com/flutter/flutter
- Flutter Gallery patterns (reference): https://github.com/flutter/gallery
- Riverpod: `rrousselGit/riverpod` — https://github.com/rrousselGit/riverpod
- go_router: `flutter/packages` — https://github.com/flutter/packages/tree/main/packages/go_router
- flutter_animate: `gskinnerTeam/flutter_animate` — https://github.com/gskinnerTeam/flutter_animate
- flutter_slidable: `letsar/flutter_slidable` — https://github.com/letsar/flutter_slidable
- Hive: `isar/hive` — https://github.com/isar/hive
- Dio: `cfug/dio` — https://github.com/cfug/dio
- geolocator: `Baseflow/flutter-geolocator` — https://github.com/Baseflow/flutter-geolocator
- Material color utilities: https://github.com/material-foundation/material-color-utilities
- Lottie (optional motion vocabulary): https://github.com/airbnb/lottie
- Rive (optional, for ritual interactions later): https://github.com/rive-app/rive-flutter

Design + accessibility specs referenced by `optimizeUI.md`:

- Apple HIG: https://developer.apple.com/design/human-interface-guidelines/
- Material Design: https://m3.material.io/
- WCAG contrast: https://www.w3.org/WAI/WCAG21/quickref/

### 11.2 Top-tier app UI inspirations (pattern-level)

- Things 3: spacing rhythm, calm hierarchy, micro-interactions
- Apple Weather: card hierarchy and readable overlays
- Apple Health: summary cards + “quiet data density”
- Headspace / Calm: ritual pacing, quiet motion, “afterglow” states
- Notion: typography clarity + structured sections
- Linear: precise spacing + motion discipline for state transitions
- Arc Browser: premium “calm chrome” patterns (no noisy UI)
- Readwise Reader: editorial reading layout and spacing discipline

### 11.3 Design tools (workflow)

- Figma: layout + tokens + component library
- Framer: interaction prototyping
- Principle / After Effects: timing references for ritual reveals
- Lottie (optional later): celebratory but restrained micro-moments

### 11.4 Pattern libraries (flow references)

- Mobbin: https://mobbin.com/
- ScreensDesign: https://screensdesign.app/
- UI Sources: https://www.uisources.com/
- Banani: https://banani.co/

---

## 12) Beauty Bar Checklist (Release Gate)

Before shipping a screen:

1. Hierarchy obvious in 1 second
2. Contrast holds under glass
3. Text scaling doesn’t clip
4. Motion is tokenized + reduce-motion safe
5. Loading / empty / error / offline / blocked are premium
6. One background language (vary intensity only)
7. One glass language (tiers only)
8. One spacing rhythm (no random paddings)
9. Performance holds (avoid stacked blurs)
10. iOS/Android parity (native-feeling, shared soul)
