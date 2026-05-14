# Complete All Development for App Store Release

## Goal

Ship Botanica as the best-in-class offline-first plant care app on the App Store. Complete all 136 remaining execution plan items across 20 topics — from design system polish to release readiness — achieving a premium, editorial-quality experience that stands out in the plant care category.

## What I Already Know

### Codebase State
- 161 Dart source files, well-structured (features/domain/data/services/core layers)
- Riverpod state management, go_router navigation, Hive local DB
- 5 main tabs: Garden, Calendar, Discover, Daily, Profile
- Design system established: BotanicaTokens, glass tiers, Fraunces + Jakarta Sans typography
- Weather integration (Open-Meteo), AI insights (OpenAI-compatible), notifications, camera/journal
- 69/205 execution plan items completed (~34%)

### What's Built (functional)
- Core navigation + onboarding + permissions flow
- Garden screen with plant cards, swipe actions
- Calendar with watering dots + agenda
- Daily Flower ritual with 7 culture modes (Tarot, Zodiac, Almanac, Omikuji, Runes, Ogham, Just Flower)
- Discover with dual catalog (curated + plantsidea library, 300+ plants)
- Plant Detail with tabs (Overview, Care, Journal, Logs)
- Profile with settings, language, units, belief mode
- Journal (photo + diary + share cards)
- Tasks with slidable actions
- AI note integration (opt-in, cached)
- CI/CD (GitHub Actions: gitleaks + flutter build + signed AAB release)

### What's Incomplete (136 items)
- **Design System**: card padding standardization, icon alignment, button hierarchy, dark mode contrast
- **Garden & Tasks UX**: Today card premium feel, task completion animations, room batch actions, swipe consistency
- **Plant Editing**: dedicated edit screen, cover photo, rooms filter, sorting, search, archive
- **Discover**: recommendations, trending tags, filter improvements, recently viewed, favorites
- **Journal**: mood chips, match framing overlay, compare slider, entry deletion/editing
- **Reminders**: premium snooze sheet, per-plant overrides, DST handling, undo snackbar
- **Motion**: standardized entrance animations, haptics, press depth, hero transitions, tab transitions
- **Species Data**: expanded schema (toxicity, origin, growth rate, mature size, care cadence)
- **Scan UX**: confidence UI, refinement flow, offline fallback, camera framing guide
- **Accessibility**: RTL validation, tap targets, semantics labels, text scaling, contrast, reduce-motion
- **Offline Media**: image compression, storage health, safe deletion, edit entries
- **Release**: splash screen, store listing copy, screenshot templates, permissions strings, QA checklist

### Technical Constraints
- Flutter 3.24.x (SDK ^3.5.3)
- Offline-first (Hive), no backend server
- 4 locales: en, zh, es, ar (RTL)
- Placeholder images throughout (stable paths for future art drop-in)
- No Flutter SDK on current machine (code-only workflow, delegate builds to CI)

## Assumptions (temporary)

- Placeholder images are acceptable for initial App Store submission (can be replaced later)
- No new dependencies needed beyond what's in pubspec.yaml
- All work targets the existing `main` branch
- App Store submission = iOS App Store (Apple) as primary target
- The 136 items in EXECUTION_PLAN.md represent the complete scope

## Open Questions

(none — all resolved)

## Execution Strategy

**Dependency-layered approach** (chosen by user):

### Layer 1: Foundation (Design System + Data)
- Topic 1: Design System completion (card padding, icon alignment, button hierarchy, dark mode)
- Topic 5 + 14: Species Data expansion (schema, tags, care cadence, localization)

### Layer 2: Feature UX Completion
- Topic 6: Garden & Tasks UX (Today card, animations, batch actions, swipe consistency)
- Topic 7: Journal & Diary polish (mood chips, compare slider, deletion/editing)
- Topic 12: Plant Editing & Organization (edit screen, rooms, sorting, search, archive)
- Topic 13: Discover Experience (recommendations, tags, filters, recently viewed)
- Topic 15: Reminders & Scheduling (snooze, DST, undo, notification copy)
- Topic 16: Offline Media & Storage (compression, health screen, safe deletion)
- Topic 17: Scan & Identification UX (confidence UI, refinement, offline fallback)

### Layer 3: Motion & Polish
- Topic 3: Calendar micro-interactions (streak, dots animation)
- Topic 11: Daily Save/Share (share card premium, copy note, deterministic output)
- Topic 18: Motion & Micro-interactions (entrance animations, haptics, hero transitions)

### Layer 4: Accessibility & i18n
- Topic 9 + 19: Full accessibility pass (RTL, tap targets, semantics, contrast, text scaling)

### Layer 5: QA & Release Readiness
- Topic 2: Weather tests
- Topic 8: AI rate-limit + copy action
- Topic 10 + 20: Performance, builds, splash, store listing, QA checklist

## Requirements (evolving)

- Complete all 136 remaining EXECUTION_PLAN.md items
- Achieve premium visual quality across all screens (light + dark)
- Full accessibility compliance (RTL, tap targets, contrast, semantics)
- All 4 locales complete (en, zh, es, ar)
- App Store metadata ready (screenshots, description, keywords)
- Zero critical bugs, no crashes on golden paths

## Acceptance Criteria (evolving)

- [ ] All 205 EXECUTION_PLAN.md items checked off
- [ ] `flutter analyze` clean (zero warnings)
- [ ] `flutter test` green (all widget + unit tests pass)
- [ ] iOS release build succeeds
- [ ] Android release build succeeds (signed AAB)
- [ ] Dark mode passes contrast checks on all key screens
- [ ] RTL (Arabic) renders correctly on all tabs
- [ ] Text scale 1.6x doesn't clip CTAs
- [ ] All placeholder assets have stable paths
- [ ] App Store listing copy ready in EN + ZH

## Definition of Done

- All execution plan items completed and verified
- Tests added for new functionality (widget + unit)
- `flutter analyze` + `flutter test` green
- CI pipeline passes (gitleaks + build)
- No regressions in existing features
- Dark mode + RTL validated
- Store listing materials prepared

## Out of Scope (explicit)

- Backend/server infrastructure
- Real botanical photography (placeholder-based for v1.0)
- Paid features / in-app purchases
- Analytics/telemetry integration
- App Store submission process itself (just preparation)
- Marketing website

## Technical Notes

- Router: `lib/app/routing/app_router.dart` (GoRouter with ShellRoute)
- Theme: `lib/app/theme/` (tokens, glass, semantics, weather mood)
- Core widgets: `lib/core/widgets/` (scaffold, nav pill, buttons, chips, glass card, state card)
- Features: `lib/features/` (garden, calendar, discover, daily, profile, tasks, journal, scan, species, etc.)
- Data: `lib/data/` (Hive local DB, repositories, migrations)
- Services: `lib/services/` (AI, care, environment, journal, notifications, permissions, photos, plants)
- Assets: `assets/data/` (species_seed.json, plantsidea.json, daily_flower_*.json)
- L10n: `lib/l10n/` (ARB files for en, zh, es, ar)
