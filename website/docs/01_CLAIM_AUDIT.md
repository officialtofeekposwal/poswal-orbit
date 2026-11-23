# Website Claim Audit

Every claim proposed for the official Poswal Orbit website is cross-referenced against codebase evidence. No speculative, unmeasured, or marketing claims are permitted.

| # | Proposed Site Claim | Exact Codebase Evidence (File:Line) | Audit Decision | Reasoning / Required Phrasing |
|---|---|---|---|---|
| 1 | **Offline-first architecture** | `lib/data/database/app_database.dart:18` (local Drift SQLite), `pubspec.yaml` (no cloud DB) | **Keep** | Factual. All data read/write runs against local SQLite database on-device. |
| 2 | **Zero network tracking & telemetry** | `pubspec.yaml` (0 analytics/Firebase/telemetry packages) | **Keep** | Factual. Zero third-party trackers or analytics SDKs bundled in application. |
| 3 | **Release builds omit INTERNET permission** | `android/app/src/main/AndroidManifest.xml:1` (no `<uses-permission android:name="android.permission.INTERNET"/>`) | **Keep with exact phrasing** | Must say: *"Release builds do not request the INTERNET permission. Debug and CI test builds may request it for developer tooling."* |
| 4 | **4:00 AM day boundary** | `lib/domain/logic/day_boundary_engine.dart:10` (`dayBoundaryHour = 4`) | **Keep** | Verified. Check-ins between 12:00 AM and 3:59 AM count toward prior calendar day. |
| 5 | **EWMA habit consistency score** | `lib/domain/logic/habit_score_engine.dart:14` (exponentially weighted moving average) | **Keep** | Verified. Inspired by Loop Habit Tracker mathematical algorithm. |
| 6 | **Streak freeze logic** | `lib/domain/logic/streak_freeze_engine.dart:22` | **Keep** | Verified in logic engine and test suite. |
| 7 | **Natural language task quick add** | `lib/domain/logic/quick_add_parser.dart:15` (`Pay rent tomorrow 4pm !high #home`) | **Keep** | Verified. Pure Dart parser extracts date, time, priority chip, and project tag. |
| 8 | **Trilingual support (EN, HI, UR)** | `lib/l10n/app_en.arb`, `app_hi.arb`, `app_ur.arb`, `pubspec.yaml` (Noto fonts) | **Keep** | Verified. Noto Sans Devanagari and Noto Nastaliq Urdu bundled offline with RTL mirroring. |
| 9 | **228 automated tests passing** | `flutter test --no-test-assets` (228 tests across 39 files) | **Keep as build-time count** | Verified live in CI run 45143104096. Use CI badge or build-time variable. |
| 10 | **Apple HIG & Liquid Glass inspiration** | `lib/core/theme/poswal_tokens.dart:12` (concentric radii, blur layers) | **Keep with exact phrasing** | Must state: *"Inspired by Apple's Human Interface Guidelines. Not affiliated with or endorsed by Apple Inc."* |
| 11 | **Status: Pre-release** | `github.com/officialtofeekposwal/poswal-orbit/releases/tag/v0.9.0-beta.1` | **Keep** | Verified. Pre-release tag v0.9.0-beta.1 exists with CI-built APKs. |
| 12 | **iOS Verification Status** | `docs/IOS_STATUS.md:1`, `ios/OrbitWidget/OrbitWidget.swift` | **Mark unverified** | Must say honestly: *"iOS code written, not yet verified on hardware (no Mac available). Not available on App Store."* |
| 13 | **Play Store Status** | No listing on Google Play Store | **Mark unverified** | Must say honestly: *"Not published on Google Play. Sideload via GitHub Release or CI."* |
| 14 | **"60fps on all devices"** | No physical hardware profile across low-end devices | **Remove / Reword** | Prohibited as blanket claim. Reword to: *"Designed for a 60fps frame budget using lightweight canvas painting instead of runtime fragment shaders."* |
| 15 | **"WCAG AAA verified"** | `test/domain/wcag_contrast_audit_test.dart:1` verifies text $\ge 4.5:1$ (AA) | **Reword to AA** | All text tokens are verified $\ge 4.5:1$ (WCAG AA). Large headings achieve AAA. Claim: *"WCAG AA contrast verified across light, dark, and OLED."* |
| 16 | **"Battery efficient / Zero battery drain"** | No battery instrumentation benchmark report exists | **Remove** | Unverified. Omit from website copy. |
| 17 | **"Instant synchronization"** | No cloud sync exists | **Remove** | Prohibited. App is strictly 100% offline local-only. |
