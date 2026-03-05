# Botanica — Execution Plan (10 Topics / 100+ items)

This file keeps a traceable, step-by-step execution checklist for building
Botanica into a premium, “extraordinary” app while staying offline‑first.

Rule: UI / Design / Harmony first.

---

## Topic 1 — Design System (Extraordinary UI)

- [x] Define spacing scale (`xs/s/m/l/xl/2xl`) in `BotanicaTokens`
- [x] Create reusable gap widgets to replace ad-hoc `SizedBox`
- [x] Establish a consistent type scale (display/headline/title/body/label)
- [x] Ensure line-heights and letter-spacing feel editorial (Fraunces + Jakarta)
- [x] Rework glass surfaces (blur, borders, shadows) into 2–3 tiers
- [x] Standardize modal sheet styling via shared helper
- [ ] Standardize card padding across screens (14/16/18 rhythm)
- [ ] Refine icon sizing and baseline alignment rules
- [ ] Add subtle motion defaults for page sections (fade + slide + blur)
- [ ] Improve button hierarchy (Filled / Tonal / Outlined) consistency
- [ ] Validate dark mode contrast on key screens

---

## Topic 2 — Weather & Environment (Open‑Meteo)

- [x] Replace OpenWeather client with Open‑Meteo client (free endpoint)
- [x] Request `temperature_2m`, `relative_humidity_2m`, `weather_code`
- [x] Implement timezone handling (`timezone=auto` or explicit)
- [x] Add caching (TTL) to avoid redundant network calls
- [x] Keep offline fallback stable (use last snapshot)
- [x] Ensure geolocator permission flow remains progressive disclosure
- [x] Map Open‑Meteo `weather_code` → internal display label/icon
- [x] Add unit conversion support (°C/°F)
- [ ] Add tests for response parsing + snapshot mapping
- [x] Ensure failures degrade gracefully (no blocking UI)

---

## Topic 3 — Calendar & Watering History

- [x] Add Calendar as a bottom tab (always visible)
- [x] Ensure Water logs appear as dots in month grid
- [x] Add “agenda” list for the selected day (care + notes)
- [x] Add quick “Watered” action from calendar day sheet
- [x] Ensure `CareLog` write paths are consistent (Task complete, Water now)
- [x] Add ability to filter log types (Water / Fertilize / Mist / Other)
- [x] Improve month navigation (swipe + haptic + animated header)
- [ ] Add “streak” / summary (optional, subtle, not gamified)
- [ ] Add widget tests for month grid + selection + dots rendering
- [ ] Add RTL layout validation for calendar
- [ ] Polish micro‑interactions (selection glow, animated dots)

---

## Topic 4 — Daily Flower Ritual (Culture Modes)

- [x] Enforce gating: no mode → no daily flower
- [x] Enforce gating: western zodiac requires birthdate or manual sign
- [x] Implement Tarot: deal 4 → user picks 1 → persist per-day
- [x] Add Almanac (Ganzhi placeholder → later real lunar almanac)
- [x] Add Japan: Omikuji (fortune label + meaning copy)
- [x] Add Nordic/Viking: Rune (glyph + name)
- [x] Add Celtic: Ogham (id + label)
- [x] Ensure only one mode is active (Settings)
- [x] Keep content deterministic per day for sharing
- [x] Add localization coverage for all new mode strings

---

## Topic 5 — Plant Library Data (JSON)

- [x] Keep `assets/data/species_seed.json` as source of truth
- [ ] Expand schema: toxicity, origin region, growth rate, mature size
- [ ] Expand care defaults: rotate/prune/repot/check pests cadence
- [ ] Add locale-specific “history” and “habit” for more species
- [ ] Add tags: pet-safe, beginner, low-light, air-purifying (careful claims)
- [x] Provide image paths (placeholder now; replace later)
- [x] Create “species details” sections: story, habits, care at a glance
- [x] Ensure Discover search matches across locales (EN/中文/ES/AR)
- [x] Add tests for JSON parsing stability
- [ ] Prevent breaking changes with safe defaults

---

## Topic 6 — Garden & Tasks UX

- [ ] Make Today card feel premium (depth, spacing, info hierarchy)
- [ ] Improve task completion delight (micro animation + haptic)
- [ ] Add room-based batch actions (water all in room)
- [ ] Improve snooze UX (sheet with options)
- [ ] Ensure swipe actions have consistent labels/icons
- [x] Make task tiles open plant detail (tap)
- [x] Add quick edit sheet on plant cards
- [x] Add “Add photo” shortcut into Journal flow
- [ ] Add “why changed” view for environment adjustments
- [ ] Add task calendar view toggle (month + agenda)
- [ ] Prevent duplicate task generation edge cases
- [ ] Add tests for task completion creating next task
- [ ] Verify interactions on iOS + Android gestures

---

## Topic 7 — Journal & Diary (Personal Plant Diary)

- [x] Keep photo journal (camera/gallery) as first-class
- [x] Keep text diary entries simple and fast
- [ ] Add optional “mood” / prompt chips (subtle)
- [x] Ensure diary entries can be shared as premium card
- [x] Ensure photo entries can be shared as premium card
- [ ] Add “match framing” overlay improvements (ghost photo)
- [ ] Add compare slider usability polish
- [ ] Add entry deletion/editing (with confirmation)
- [ ] Add tests for share card rendering (smoke)
- [ ] Ensure offline media storage remains robust

---

## Topic 8 — AI Insights (Latent & Harmonious)

- [x] Keep AI opt-in (settings toggle)
- [x] Use system prompt to enforce user language output
- [x] Keep AI note embedded as a calm card (no bubbles/popups)
- [x] Cache results per day + mode (Hive)
- [ ] Add rate-limit / debounce to avoid repeated calls
- [ ] Add “copy note” action (optional)
- [x] Ensure safe content rules (no medical, no ingestion claims)
- [x] Fail silently (don’t disrupt UI)
- [x] Add tests for prompt builder correctness
- [x] Document runtime AI key entry (secure storage)

---

## Topic 9 — Accessibility & Internationalization

- [ ] Verify RTL (Arabic) on Garden/Discover/Daily/Profile/Calendar
- [ ] Ensure minimum tap targets (44px)
- [ ] Add semantics labels for key icons/buttons
- [ ] Test textScaleFactor (large fonts) for overflow issues
- [ ] Ensure contrast meets accessibility thresholds
- [ ] Ensure locale-aware dates and units formatting
- [ ] Add more ARB coverage as UI grows
- [ ] Validate focus order for forms (Add Plant)
- [ ] Ensure animations respect reduce-motion settings
- [ ] Add a small accessibility test checklist

---

## Topic 10 — QA / Performance / Builds

- [x] Keep `flutter analyze` clean
- [x] Keep `flutter test` green (add widget tests as features grow)
- [ ] Add smoke test for routing (tabs + critical routes)
- [x] Verify iOS build (simulator) after dependency pins
- [x] Verify Android build (debug) as well
- [ ] Keep startup fast (lazy-load heavy JSON/assets)
- [ ] Add simple repository caching where needed
- [x] Ensure no secrets committed (key never embedded in the binary)
- [x] Run `flutter format` on changed files
- [ ] Keep changelog notes for major UI changes

---

## Topic 11 — Daily Save / Share (Ritual Cards)

- [x] Implement “Save” for Daily Flower (local favorites)
- [x] Add a Daily Flower share-card renderer (image output)
- [ ] Ensure share card looks premium in light/dark
- [x] Include mode + variant label on the share card
- [x] Include care-at-a-glance rows on the share card
- [ ] Add “Copy note” action for the AI note (optional)
- [x] Add a “Saved” affordance + haptic feedback
- [ ] Add tests for share card rendering (smoke)
- [ ] Ensure deterministic output per day (same inputs → same card)
- [x] Make share graceful when assets are placeholders

---

## Topic 12 — Plant Editing & Organization

- [ ] Add a dedicated Edit Plant screen (beyond the quick sheet)
- [ ] Support editing cover photo (pick latest journal photo)
- [ ] Add “Rooms” filter on Garden (chips or sheet)
- [ ] Add batch actions per room (Water all / Snooze all)
- [ ] Add sorting options (recent, name, due soon)
- [ ] Add quick search on Garden (nickname/species/room)
- [ ] Add tests for plant edits persisting to Hive
- [ ] Add safe “Archive plant” flow (not destructive)
- [ ] Improve empty states (first plant guidance)
- [ ] Add analytics hooks (local-only, optional later)

---

## Topic 13 — Discover Experience (Extraordinary)

- [ ] Add “Recommended for you” section (based on settings/unit/culture)
- [ ] Add trending tags (Beginner, Low light, Pet-safe)
- [ ] Improve filter sheet UI (preview counts + reset)
- [ ] Add a “recently viewed” section (local)
- [ ] Add a “favorites” species section (local)
- [ ] Add search suggestions (chips) when field is focused
- [ ] Improve card density + spacing for readability
- [ ] Add skeleton loading state for cards
- [ ] Add widget tests for filter+search combinations
- [ ] Validate RTL layout for Discover card rows

---

## Topic 14 — Species Data Expansion (JSON + UI)

- [ ] Expand JSON schema: origin region, toxicity notes, growth rate
- [ ] Add mature size + growth habit fields
- [ ] Add care cadence fields for prune/repot/check pests/wipe leaves
- [ ] Add “Care warnings” copy (safe, non-medical)
- [ ] Add localized “history” and “habit” for more locales
- [ ] Add search indexing across new fields
- [ ] Ensure backward-compatible parsing with defaults
- [ ] Add tests for schema evolution (missing keys)
- [ ] Add a “Care at a glance” grid on Species details
- [ ] Add a “Good for” tags row (careful claims)

---

## Topic 15 — Reminders, Snooze, and Scheduling

- [ ] Implement a premium Snooze sheet (1h / 3h / tomorrow / weekend)
- [ ] Add per-plant reminder preference overrides (optional)
- [ ] Handle DST/timezone changes robustly (resync strategy)
- [ ] Add “mark done” undo snackbar for tasks
- [ ] Ensure notification IDs remain stable across edits
- [ ] Add tests for snooze alignment to reminder time
- [ ] Add tests for “done” → next task scheduling
- [ ] Add “skip this time” action (does not log)
- [ ] Improve notification copy per task type
- [ ] Add a notification permission education screen (soft ask)

---

## Topic 16 — Offline Media & Storage Robustness

- [ ] Add image compression presets (journal vs share card)
- [ ] Add storage health screen (size, count, cleanup)
- [ ] Add safe deletion of single journal entry (confirm)
- [ ] Add edit diary entry (confirm + revision history optional)
- [ ] Ensure iOS photo permissions edge cases are handled
- [ ] Add tests for photo storage path generation
- [ ] Add fallback UI when a file is missing (placeholder)
- [ ] Improve “match framing” overlay strength controls
- [ ] Improve compare slider ergonomics
- [ ] Ensure exports work without blocking UI (isolates if needed)

---

## Topic 17 — Scan & Identification UX

- [ ] Make scan tips feel premium (microcopy + iconography)
- [ ] Add a confidence UI for scan results (bars + explanation)
- [ ] Add a “not sure?” refinement question flow (chips)
- [ ] Add offline fallback: manual selection from library
- [ ] Improve camera framing guide + edge detection hinting
- [ ] Add tests for scan flow routing (happy path)
- [ ] Ensure permissions are progressive disclosure (no hard blocks)
- [ ] Cache last scan result (local) for quick retry
- [ ] Add graceful timeout UI for slow networks
- [ ] Add a short scan tutorial in onboarding (optional)

---

## Topic 18 — Motion, Harmony, and Micro‑Interactions

- [ ] Standardize page section entrance animations
- [ ] Add subtle haptics for key success moments (done/save/share)
- [ ] Ensure animations respect reduce‑motion settings
- [ ] Add interactive “press depth” on primary cards/buttons
- [ ] Smooth tab transitions (Daily/Discover/Profile/Garden)
- [ ] Improve bottom navigation blur + border refinement
- [ ] Add shimmer skeletons for async content (consistent style)
- [ ] Add hero transitions for plant images (optional)
- [ ] Keep motion durations aligned to `BotanicaTokens`
- [ ] Validate performance (no jank on scroll)

---

## Topic 19 — Accessibility & Localization Completion

- [ ] Add semantics labels for all icon-only buttons
- [ ] Validate large text (1.3–1.6) across key screens
- [ ] Verify RTL alignment + mirroring on all tabs
- [ ] Ensure minimum hit targets (44px) everywhere
- [ ] Ensure contrast meets accessible thresholds
- [ ] Add locale-aware date formatting for diary/logs
- [ ] Add ARB completeness checks (missing keys)
- [ ] Add language fallback behavior documentation
- [ ] Add accessibility QA checklist in repo
- [ ] Add widget tests for RTL smoke (routing + tabs)

---

## Topic 20 — Release Readiness (Polish + Packaging)

- [ ] Add app icon set (iOS/Android) + adaptive icon
- [ ] Add refined splash screen (calm, minimal)
- [ ] Verify iOS/Android build flavors (debug/release)
- [ ] Add basic crash-safe logging (local, non-sensitive)
- [ ] Ensure permissions strings are accurate and localized
- [ ] Add Store listing copy (EN/中文/ES/AR)
- [ ] Add screenshot templates (placeholder images OK)
- [ ] Validate startup performance (lazy-load heavy assets)
- [ ] Ensure licenses/credits are up to date
- [ ] Create a short QA checklist for pre-release builds
