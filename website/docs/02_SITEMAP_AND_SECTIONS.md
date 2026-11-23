# Website Specification & Section Architecture

The official Poswal Orbit website blends the **tactile, dark mesh-gradient and inset-hairline aesthetics of BitChord** with the **structured editorial numbering (`01 //`), monospace micro-eyebrows, and spec-sheet honesty of TeleDrive**.

---

## 1. Global Navigation & Layout Architecture

- **Sticky Top Bar (`00`)**:
  - Left: Poswal Orbit wordmark + animated gold planet glyph (`orbit.svg`).
  - Center (Desktop): Numbered navigation index:
    `01 Demo · 02 Features · 03 Design · 04 Privacy · 05 Languages · 06 Get It · 07 Specs · 08 FAQ`
  - Right:
    - Language switcher pill: `EN | हिन्दी | اردو` (sets document language, canonical URL, and triggers RTL layout for Urdu).
    - Theme switcher pill: `System / Dark / Light / OLED` (persisted in `localStorage` inside `try/catch`).
    - CTA button: `Get App` (smooth scrolls to section `06 Get It`).
  - Mobile: Collapses into a floating glass bar with hamburger drawer / sheet ($44\times 44\text{px}$ touch targets).

---

## 2. Section-by-Section Specification

### Section 01: Hero (`01 // HERO`)
- **Goal**: Communicate the core purpose of Poswal Orbit in under 10 seconds.
- **Headline**: `"Your whole day, in orbit."`
- **Subheadline**: `"Habits, tasks and notes in one calm app. Everything stays on your phone."`
- **Status Eyebrow Pill**: `[ PRE-RELEASE · v0.9.0-beta.1 · 100% OFFLINE ]`
- **Action Buttons**:
  - Primary CTA: `Get the app` (direct anchor to verified download options).
  - Secondary CTA: `View on GitHub` (links to `github.com/officialtofeekposwal/poswal-orbit`).
- **Visual Scene (CSS 3D)**:
  - Central 3D phone mockup tilted at `perspective(1000px) rotateY(-12deg) rotateX(8deg)`.
  - Tilts dynamically with pointer motion on desktop; follows gentle gyro orientation on mobile (only when supported without permissions).
  - Concentric CSS orbit rings tilted in 3D containing 3 orbiting badges:
    - Inner Orbit: Habit streak chip (Teal `#14B8A6`).
    - Outer Orbit: Task due chip (Coral `#FF7A59`).
    - Central Gravity: Markdown note snippet (Violet `#8B7CFF`).
  - Real vs Illustration Label: `[ Illustration · Real device screenshots will replace mockups after phone verification ]`.
- **Fact Strip**:
  - `01. PLATFORM`: Android (pre-release) · iOS (code written, unverified)
  - `02. PRIVACY`: 0 trackers · 0 accounts · 0 network calls in release
  - `03. LOCALIZATION`: English · हिन्दी · اردو (True RTL)
  - `04. LICENCE`: MIT open-source

---

### Section 02: Interactive Simulator (`02 // SIMULATOR`)
- **Goal**: Allow visitors to experience the core mechanics immediately without installing.
- **Interaction A (Habit Check-in)**:
  - Tapping 3 sample habits ("Morning Walk", "Drink 2L Water", "Read 20 Mins") fills the SVG progress ring from 33% $\to$ 66% $\to$ 100% and increments the streak counter.
- **Interaction B (Quick-Add Task Parser)**:
  - Live interactive input box with suggestions (e.g. `Pay rent tomorrow 4pm !high #home`).
  - As visitor types or taps suggestions, real-time parsed badges appear below:
    - Due Date: `Tomorrow 4:00 PM`
    - Priority: `High (Urgent)`
    - Project: `#home`
- **Label**: `[ Simplified interactive simulation of real Dart domain logic ]`. Fully keyboard navigable.

---

### Section 03: Core Features (`03 // FEATURES`)
Six numbered interactive cards (`01 //` to `06 //`) with hover/tap expansion:
1. `01 // TODAY`: Unified daily command center combining scheduled habits and tasks due today with concentric progress ring.
2. `02 // HABITS & STREAKS`: Exponentially Weighted Moving Average (EWMA) score, streak freeze protection, 14-week visual heatmap.
3. `03 // TASKS & NATURAL LANGUAGE`: Natural text parsing, priority flags, project hashtags, checklist subtasks, repeat schedules.
4. `04 // NOTES & JOURNAL`: Markdown editor with live dimmed syntax tokens, line formatting toolbar, inline checklist toggles.
5. `05 // NOTIFICATIONS & WIDGETS`: 7-day rolling notification window, health-check status screen, home screen glance widgets.
6. `06 // DATA FREEDOM`: Daily 7-snapshot automatic rotation, transactional JSON import/export, Loop Habit Tracker CSV migration.

---

### Section 04: Design System (`04 // DESIGN SYSTEM`)
- **Goal**: Explain why the app feels calm and tactile.
- **Concept**: *Liquid Glass on Apple HIG*.
- **Rules Illustrated**:
  - Glass only on navigation & control surfaces (solid content surfaces for zero eye strain).
  - Concentric border geometry ($R_{outer} = R_{inner} + \text{padding}$).
  - Quiet Aurora: Pure CSS gradient drift, completely disabled when `prefers-reduced-motion` is active.
- **Interactive Control**: A live CSS slider adjusting `backdrop-filter: blur(Npx)` and surface opacity on a sample card so users experience the glass layer directly.
- **Disclaimer**: *"Inspired by Apple's Human Interface Guidelines. Not affiliated with or endorsed by Apple Inc."*

---

### Section 05: Privacy & Verification (`05 // PRIVACY`)
- **Philosophy**: *"Verify, don't trust."*
- **What Poswal Orbit does not do**: Zero accounts, zero cloud servers, zero ads, zero analytics SDKs.
- **Permission Transparency**:
  - Release builds: **0 `INTERNET` permission requested**.
  - Local permissions requested: `POST_NOTIFICATIONS` (reminders), `SCHEDULE_EXACT_ALARM` (timely check-ins), `VIBRATE` (haptic tactile feel), `RECEIVE_BOOT_COMPLETED` (reschedule alarms after phone restart).
- **Audit Steps**: Exact instructions showing how any user can decompile the release APK with `aapt dump permissions` or inspect `AndroidManifest.xml` on GitHub.

---

### Section 06: Trilingual Proof & RTL (`06 // LANGUAGES`)
- **Languages Supported**: English, हिन्दी (Hindi), اردو (Urdu RTL).
- **Live Proof Switcher**: A side-by-side interactive card allowing visitors to flip the layout between English LTR and Urdu RTL, demonstrating true mirror geometry, right-aligned baselines, and `EdgeInsetsDirectional`.
- **Marquee Strip**: Slow, calm scrolling marquee of translated keywords (`habits · आदतें · عادات · tasks · कार्य · کام`). Pauses on hover and when reduced motion is preferred.

---

### Section 07: Download & Install (`07 // GET IT`)
- **Honest Routing Matrix**:
  - **Android Pre-Release**: Direct download link to `Poswal-Orbit-v0.9.0-beta.1-release.apk` hosted on GitHub Releases, with SHA-256 checksum and release date.
  - **Android CI Debug APK**: Link to `docs/INSTALL_DEBUG_APK.md` for developers who want automated CI artifacts.
  - **iOS Status**: *"Code written, not yet verified on hardware (no Mac available). Not available on App Store."*
  - **Google Play Status**: *"Not published on Google Play. Sideload via GitHub Release."*

---

### Section 08: Architecture & Specs (`08 // SPECS`)
TeleDrive-style technical specifications table:
- Framework: Flutter 3.50.1 / Dart 3.14.0
- State Architecture: Riverpod 2.x
- Persistence: SQLite 3 via Drift (Type-safe, transactional `SAVEPOINT` rollbacks)
- Architecture Model: Pure domain engines (100% Flutter-free Dart core for streak/score/parser)
- Automated Test Suite: 228 verified unit, widget, and migration tests in Linux CI

---

### Section 09: Frequently Asked Questions (`09 // FAQ`)
Accessible `<details>` accordion elements:
1. Is Poswal Orbit really 100% offline? (Yes, release builds lack network permission).
2. Where is my data stored? (In an encrypted-ready SQLite database on your device storage).
3. Why does the day boundary start at 4:00 AM? (To protect night owls from losing streaks after midnight).
4. When is the iOS version coming? (As soon as hardware verification on a physical Mac and iPhone can be conducted).
5. How can I contribute? (Check out `docs/GOOD_FIRST_ISSUES.md` and `CONTRIBUTING.md` on GitHub).

---

### Section 10: Open Source & Roadmap (`10 // OPEN SOURCE`)
- Roadmap status matrix:
  - Completed: Core engines, SQLite v3 migration, trilingual localization, unslop audit, CI release automation.
  - In Progress: Physical phone verification, community feedback.
  - Planned: iOS hardware verification, tablet responsive layout.
- Links: GitHub repository, MIT License, Good First Issues, Security Policy (`SECURITY.md`).

---

### Section 11: Footer (`11 // FOOTER`)
- Zero-tracking statement: *"This website sets zero cookies, loads zero analytics, and calls zero third-party hosts."*
- Credits: Plus Jakarta Sans (OFL), Inter (OFL), Noto Fonts (OFL), Phosphor Icons (MIT).
- Language links, repository link, and release RSS/Atom link.
