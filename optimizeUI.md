# Botanica “Win on Beauty” — Harmony Optimization Task Book (All Screens, One System)

This is built to let you polish *everything at once* by tightening the **system**, then letting every screen inherit the same beauty rules (instead of hand-tuning screen-by-screen forever).

---

## 0) Definition of Done (Beauty Bar you must hit)

Every screen ships only if it passes all of these:

1. **Hierarchy is obvious in 1 second** (title → primary action → next action → supporting info). Apple explicitly emphasizes hierarchy as a core principle. ([Apple Developer][1])
2. **Text stays readable under glass** (meets contrast targets; no “pretty but foggy”). WCAG contrast minimums: 4.5:1 normal text, 3:1 large text. ([W3C][2])
3. **Dynamic Type doesn’t break layout** (1.2–1.6 scale: no clipped CTAs, no overlapping chips). Apple typography guidance stresses supporting accessibility behaviors (esp. custom fonts). ([Apple Developer][3])
4. **Motion feels intentional** (no random bounces; durations/easings are tokenized; reduce-motion supported). Material motion tokens/specs exist for consistency. ([Material Design][4])
5. **Every state is premium** (loading, empty, offline, error, permission blocked).
6. **One background language** across tabs (same mood, different intensity).
7. **One glass language** (tiers are semantic; blur/border/shadow never ad-hoc).
8. **One spacing rhythm** (no “close enough” paddings).
9. **Performance holds** (glass + blur doesn’t drop frames on mid devices).
10. **Cross-platform parity** (Android/iOS feel native but share Botanica soul).

---

## 1) Operating Model (How you polish all screens simultaneously)

### 1.1 Build a “Harmony System” first (the real work)

You will ship beauty by producing these *system artifacts* before touching screen polish:

**A) Tokens (single source of truth)**

* Typography tokens (your Fraunces + Plus Jakarta Sans system)
* Color tokens + semantic roles
* Surface tokens: **GlassTier 1/2/3**
* Elevation/shadow tokens
* Spacing + radii tokens
* Motion tokens (durations/easings/springs)
* Haptic tokens (tap/select/success/complete/reveal)

**B) Templates (4 screen archetypes)**

* Template L: Editorial List (Garden, Tasks, Discover list)
* Template D: Editorial Detail (Plant Detail, Species Detail)
* Template R: Ritual Immersive (Daily)
* Template S: Settings & Forms (Profile, Add Plant, Permissions, Onboarding)

**C) Component Kit (used everywhere)**

* GlassCard (tiered)
* Buttons (filled/outlined/text + glass-filled variant)
* Chips/tags
* List rows / tiles
* Text field / search field
* Bottom nav pill
* Sheets/dialogs
* Skeleton + empty state + error state components

> Once A/B/C are locked, polishing all screens becomes “apply template + component kit,” not bespoke art.

---

## 2) Workstream A — Visual System (Tokens & Rules)

### A1) Glass Tiers (semantic, not decorative)

**Task**

* Implement `GlassTier { primary, secondary, subtle }` and forbid raw blur/opacity/shadow usage outside the component.
* Define per-tier:

  * blur radius
  * border width + border color role
  * shadow recipe (elevation token)
  * optional inner highlight gradient

**Acceptance**

* Dev can change *one token* and see consistent updates across the entire app.
* No “random opacity numbers” in screens (only tokens).

**Guardrails**

* Glass must preserve hierarchy (content > chrome). Apple’s HIG repeatedly stresses clear hierarchy. ([Apple Developer][1])
* Any glass-on-photo surface gets an automatic **scrim strength** ramp if contrast drops below threshold (use WCAG targets as hard constraints). ([W3C][2])

---

### A2) Typography Refinement (editorial but accessible)

**Task**

* Define semantic text styles (do not style by size directly):

  * `displayHero`, `headline`, `title`, `body`, `bodyMuted`, `label`, `chip`
* Add rules:

  * Fraunces only for **non-interactive** display/headlines + ritual quotes
  * Plus Jakarta Sans for all interactive labels/forms
  * Minimum sizes for tap labels in accessibility settings
* Implement large font scaling QA and fixes (wrap, reflow, adaptive spacing)

**Acceptance**

* Dynamic Type / font scaling keeps CTAs visible and readable (Apple expects custom fonts to behave well with accessibility features). ([Apple Developer][3])

---

### A3) Color System (warm calm + reliable contrast)

**Task**

* Create semantic color roles:

  * `bgBase`, `bgGlowA/B`, `surfacePrimary/Secondary/Subtle`
  * `textPrimary`, `textSecondary`, `textTertiary`
  * `accent`, `accentMuted`, `danger`, `success`, `warning`
  * `divider`, `border`, `focusRing`
* Dynamic color toggle (optional) must:

  * harmonize accents only (do not change base surfaces unpredictably)
  * clamp saturation and brightness to keep Botanica mood consistent

**Acceptance**

* All text meets contrast targets; labels on glass never “fade into mood.” ([W3C][2])

---

### A4) Spacing & Grid (the “editorial calm” engine)

**Task**

* Lock an 8pt baseline grid + your preferred “airy” steps (10/12/14/16/18/20/24/32).
* Define layout rules:

  * Screen padding (outer): one token
  * Section spacing: one token
  * Card internal padding: one token per card type
* Create a `BotanicaSection` wrapper used everywhere (title, optional action, content slot)

**Acceptance**

* You can take 20 random screenshots; spacing feels like one magazine layout system.

---

## 3) Workstream B — Interaction System (Motion, Haptics, Feedback)

### B1) Motion Tokens (calm, consistent, reduce-motion ready)

**Task**

* Define durations by intent:

  * micro (tap feedback)
  * small (chip select, expand)
  * medium (sheet/route transitions)
  * large (ritual reveal)
* Define easing/spring tokens from a consistent spec (Material motion provides token structure). ([Material Design][4])
* Implement `Reduce Motion`:

  * disable looping particles
  * shorten large transitions
  * remove parallax

**Acceptance**

* No screen introduces a new animation style without adding it to tokens.

---

### B2) Haptic Map (tactile punctuation, not noise)

**Task**

* Create a haptic table by action:

  * selection tick (chips)
  * primary CTA press
  * task completion
  * successful save
  * ritual reveal climax
  * error (subtle)
* Enforce: max 1 haptic per user action chain (avoid spam)

**Acceptance**

* Haptics feel intentional, never “arcade.”

---

### B3) State Design Kit (premium even when empty)

**Task**
Implement reusable components for:

* Skeleton loading (list, card, hero)
* Empty states (Garden empty, Tasks empty, Discover no results)
* Offline state (cached view + “retry”)
* Error state (calm explanation + action)
* Permission blocked state (reason + optional action; never hard-block exploration)

**Acceptance**

* Every screen has a designed state for: loading / empty / error / offline / blocked.

---

## 4) Workstream C — Component Library (the harmony multiplier)

### C1) BotanicaScaffold (global layout consistency)

**Task**

* Build a wrapper that standardizes:

  * background widget + intensity per tab
  * top padding + safe area behavior
  * default section spacing
  * scroll behavior (bouncing vs clamping per platform)

**Acceptance**

* Screens stop implementing their own scaffolding decisions.

---

### C2) Navigation Pill (already premium → make it perfect)

**Task**

* Selected label appears only for active tab (keep your minimalism)
* Add micro-motion:

  * label fade + slight slide
  * selected icon subtle scale (very restrained)
* Ensure safe-area + gesture nav compatibility

**Acceptance**

* No overlap with content on iPhones with home indicator + Android gesture nav.

---

### C3) Forms & Sheets (Add Plant, Settings, Permissions)

**Task**

* Standardize:

  * sheet corner radius + tier
  * field spacing + label style
  * validation style (quiet, not alarming)
  * CTA placement (always reachable with one-hand grip)

**Acceptance**

* Every sheet feels like the same product family.

---

## 5) Workstream D — Screen Templates (Apply Once, Improve Everywhere)

### Template L — Editorial List (Garden / Tasks / Discover list)

**Layout rules**

* Title + optional action row
* “Hero card” (Today / Summary / Search) uses **GlassTier 1**
* Content list uses **GlassTier 2**
* Chips always **Tier 3** (or Tier 2 when floating on photo)
* Primary CTA always visually discoverable and stable

**Tasks**

* Define list item anatomy (thumbnail, title, meta line, status line, tags row)
* Define swipe actions style (slidable actions share one visual language)
* Define “status semantics” (due today / overdue / upcoming)

**Acceptance**

* Garden cards, task rows, and discover cards look like siblings.

---

### Template D — Editorial Detail (Plant Detail / Species Detail)

**Layout rules**

* Hero image with controlled overlay + scrim
* Sticky section header behavior consistent
* Sections: “At a glance” → “Care” → “Journal/History”

**Tasks**

* Define hero overlay recipe to guarantee contrast (ties to WCAG). ([W3C][2])
* Define section blocks with consistent dividers, spacing, and optional action chips
* Define photo expansion behavior (tap → immersive viewer) consistent across plant/species

**Acceptance**

* Detail pages read like a premium article, not a wiki dump.

---

### Template R — Ritual Immersive (Daily)

**Layout rules**

* Minimal chrome
* One focal “reveal vessel” (orb/card/scroll area)
* Post-reveal: calm editorial card (no chat bubbles)

**Tasks (critical)**

* For each mode, design:

  1. **entry state** (anticipation)
  2. **gesture affordance** (obvious without text overload)
  3. **reveal animation** (slow-intentional)
  4. **climax haptic**
  5. **afterglow state** (share/save/reflect)
* Add a unified “Daily info sheet” pattern explaining cultural context (calm, non-judgy)

**Acceptance**

* Daily feels like the signature feature that no plant app has.

---

### Template S — Settings & Forms (Profile/Settings, Permissions, Onboarding, Add Plant)

**Layout rules**

* Clear grouping and minimal clutter
* One primary action per page
* Progressive disclosure for permission asks

**Tasks**

* Standardize settings rows (icon, title, value, chevron)
* Mode-specific profile sheet uses the same component language as Daily (consistency)
* Onboarding pages share one layout grid and motion rhythm

**Acceptance**

* Settings look premium, not like a dump of toggles.

---

## 6) Screen-by-Screen Task Checklist (Apply the System Everywhere)

### Splash

* Replace static gradient with the same background engine used app-wide (low motion)
* Add “boot calmness”: no jitter, no layout shifts

### Onboarding (3–4 pages)

* One promise per page
* CTA never moves
* Illustrations/photos follow the same tonal grading as the rest of the app

### Permissions

* One card per permission: reason → benefit → optional action
* Never hard-block exploration (allow skip + re-ask when needed)

### Garden

* Today card = Tier 1; plant cards = Tier 2; tags = Tier 3
* Plant card anatomy standardized (photo, nickname, species, tags, due line)
* Swipe actions visually consistent with Tasks

### Tasks

* Today/Upcoming/Overdue tabs match chip/segmented design language
* Slidable actions use the same motion + haptics as Garden quick actions

### Calendar

* Month grid dots use restrained color roles
* Day agenda uses the same list row component as Tasks

### Discover

* Search bar style reused in Add Plant library search
* Filter chips reuse the same chip component everywhere
* Species cards follow Template L anatomy

### Species Detail

* Detail template (Template D)
* CTA “Add to Garden” uses primary button style + consistent placement

### Add Plant

* Method selection as a calm sheet or page (Template S)
* Scan flow uses the same camera overlay language as photo add in Plant Detail

### Plant Detail

* Hero + primary actions (water/photo/note) use a single action cluster component
* Journal timeline uses a standardized timeline card component (reused later for Daily history)

### Daily

* Ritual template (Template R)
* AI note appears as editorial glass card (never chat UI)

### Profile/Settings

* Sections: Preferences / AI / Permissions / About
* Mode-specific sheet uses Daily’s language (consistency loop)

---

## 7) Performance & Accessibility Task Pack (Beauty that doesn’t break)

### P1) Contrast & Readability Gates

* Add a “contrast audit checklist” per screen
* Enforce WCAG minimum contrast for text/critical UI. ([W3C][2])

### P2) Dynamic Type / Font scaling

* Verify no clipping at 1.6
* Fraunces headlines wrap gracefully; CTAs remain tappable
* Apple’s typography guidance explicitly calls out accessibility behaviors for custom fonts. ([Apple Developer][3])

### P3) Reduce Motion

* Global toggle that disables loops/particles/parallax first
* Motion tokens still apply (shorter, simpler) ([Material Design][4])

### P4) Blur Cost Control

* Cap blur usage per screen (Tier 1 limited, Tier 2 moderate, Tier 3 minimal)
* Avoid stacking multiple BackdropFilters
* Pre-compose backgrounds where possible

---

## 8) Reference Harvest System (so you never run out of “beautiful but reasonable”)

Use production UI libraries to extract patterns **by flow** (not random screenshots):

* Mobbin (huge searchable app screenshot library) ([Mobbin][5])
* ScreensDesign (iOS app flows, onboarding/paywalls patterns) ([ScreensDesign][6])
* UI Sources (screens + flows) ([UI Sources][7])
* Banani references (free screenshot reference library; good for Things 3 flows) ([Banani][8])

**Task**

* Build a Botanica “Pattern Board” with 30–50 references per template (L/D/R/S)
* For each reference, extract:

  * spacing rhythm
  * card anatomy
  * typography hierarchy
  * motion intent
  * how they handle empty/error states

---

## 9) Your “Harmony Review” Ritual (fast, brutal, effective)

Do this every time you touch the UI system:

1. Export a **full-screen screenshot pack** (all screens, light/dark, 1.0 + 1.4 text size)
2. Lay them side-by-side and grade only 5 questions:

   * Do headers feel like one family?
   * Do cards feel like one material?
   * Do actions sit in consistent places?
   * Does any screen look louder than the others?
   * Would a stranger call it “premium” in 3 seconds?
3. Fix *system causes* first (tokens/components/templates), not per-screen hacks.
