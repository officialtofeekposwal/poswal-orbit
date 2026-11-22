# 🌟 Good First Issues for Contributors

Welcome to **Poswal Orbit**! We love open-source contributions. Below are 5 well-scoped, realistic beginner and intermediate issues designed to help you get started with the codebase.

---

### Issue 1: Add Swift WidgetKit Extension for iOS Home Screen
- **Difficulty:** Intermediate (macOS / Swift)
- **Domain:** iOS Native / `home_widget`
- **Description:** Android has 3 home widgets (Today Orbit Progress Ring, Habit Check-off, Task List) written in Kotlin. Build an equivalent WidgetKit extension using SwiftUI and iOS App Groups so iPhone users can see their Orbit progress on their Home Screen and Lock Screen.
- **Relevant Files:** `ios/Runner.xcodeproj`, `lib/data/services/home_widget_service.dart`, `docs/IOS_STATUS.md`.

---

### Issue 2: Additional First Day of Week Options (Saturday / Sunday / Monday)
- **Difficulty:** Good First Issue (Beginner)
- **Domain:** Dart / Settings UI
- **Description:** Currently, the settings screen allows choosing between Monday and Sunday as the first day of the week. In several regions (e.g. Middle East / North Africa), Saturday is the standard start of the work week. Add Saturday as an option in `lib/features/settings/presentation/settings_screen.dart` and verify that the heatmap calendar and week strip calculate columns accordingly.
- **Relevant Files:** `lib/domain/logic/date_boundary.dart`, `lib/features/settings/presentation/settings_screen.dart`, `test/domain/date_boundary_test.dart`.

---

### Issue 3: Markdown Zip Folder Export & Import
- **Difficulty:** Intermediate
- **Domain:** Pure Dart / File I/O
- **Description:** Poswal Orbit supports full JSON database snapshots and CSV exports. Add an export option that dumps all user notes as individual `.md` files in a clean ZIP archive (compatible with Obsidian / Logseq vaults), with YAML frontmatter containing tags, pinned status, and created date.
- **Relevant Files:** `lib/domain/logic/data_safety_codec.dart`, `lib/data/services/data_safety_service.dart`.

---

### Issue 4: Customizable Haptic Feedback Intensity
- **Difficulty:** Good First Issue (Beginner)
- **Domain:** Flutter UI / Haptics
- **Description:** The app has a toggle for Haptics (On/Off). Add an intensity selector in the settings screen: `Subtle` (`lightImpact`), `Medium` (`mediumImpact`), and `Crisp` (`selectionClick`).
- **Relevant Files:** `lib/features/settings/presentation/settings_screen.dart`, `lib/core/theme/poswal_tokens.dart`.

---

### Issue 5: Add Turkish (tr) and Arabic (ar) Localizations
- **Difficulty:** Good First Issue (Beginner)
- **Domain:** ARB / i18n
- **Description:** Poswal Orbit currently supports English (`en`), Hindi (`hi`), and Urdu (`ur` RTL). Add `app_tr.arb` and `app_ar.arb` translations for all existing ARB strings and verify that RTL text layout adjusts automatically for Arabic.
- **Relevant Files:** `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`, `lib/l10n/app_tr.arb`.
