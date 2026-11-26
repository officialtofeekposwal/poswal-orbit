# Poswal Orbit — Cleanup & Dead Code Audit Report (Workstream A)

> **Branch:** `feat/cleanup` (from `main` at `e34f938`)  
> **Date:** 2026-11-26  
> **Method:** Vulture-inspired confidence triage + `flutter analyze` + `dart fix --dry-run` + grep-based static scans

---

## 1. Tooling Notes
- **`flutter analyze`**: `No issues found!`
- **`dart fix --dry-run`**: `Nothing to fix!`
- **`dart_code_linter` (`metrics check-unused-files`)**: Activated `dart_code_linter 4.4.5`, however `metrics check-unused-files lib` hung on Windows console spinner with ~0% CPU usage. As instructed, fell back to deterministic grep-based static scans across `lib/`, `test/`, and `android/`.

---

## 2. Removed Items (100% Confidence Unused)
- **None.** All `.dart` files in `lib/` (outside the whitelist and `home_widget_service.dart` below) are actively imported and referenced across `lib/` or `test/`.
- **Debug prints (`debugPrint` / `print`)**: 0 occurrences found in `lib/`.
- **Real `TODO` / `FIXME` comments**: 0 occurrences found in `lib/`.

---

## 3. Maybe Unused / Unwired (Kept — Lower Confidence)
- `lib/data/services/home_widget_service.dart` (2,785 bytes):
  - **Finding:** `HomeWidgetService` and `homeWidgetBackgroundCallback` have 0 callers in `lib/` or `test/`.
  - **Why Kept:** It is the Dart-side bridge for `OrbitTodayWidgetProvider`, `OrbitHabitsWidgetProvider`, and `OrbitTasksWidgetProvider` declared in `AndroidManifest.xml` (which are whitelisted). Flagged here for future wiring or removal rather than deleting blindly.

---

## 4. Unused ARB Localization Keys (Report Only — Not Deleted)
The following **29 keys** exist in `app_en.arb` (and `app_hi.arb` / `app_ur.arb`) with no references outside `lib/l10n/app_localizations*.dart`. Per policy, they were **not deleted**:

- `greetingNight`
- `habitsProgress`
- `habitsAllDone`
- `tasksDueOverdue`
- `yourOrbitClear`
- `newHabit`
- `priorityUrgent`
- `priorityHigh`
- `priorityMedium`
- `priorityLow`
- `priorityNone`
- `notesLabel`
- `projectLabel`
- `taskDeletedToast`
- `notesPinned`
- `notesAll`
- `notesTodayJournal`
- `journalForDate`
- `widgetTodayProgress`
- `widgetQuickCheckin`
- `widgetTasksGlance`
- `designPlaygroundTooltip`
- `onboardingWelcomeTitle`
- `onboardingWelcomeDesc`
- `weeklyTrendUp`
- `weeklyTrendDown`
- `weeklyTrendSteady`
- `bestWeekdayLabel`
- `bestTimeLabel`

---

## 5. Whitelist (Explicitly Excluded from Dead-Code Removal)
- **Generated code:** `*.g.dart`, `lib/l10n/app_localizations*.dart`
- **Drift database schema & tables:** `lib/data/database/**`
- **Android Home Widget providers:** `OrbitTodayWidgetProvider`, `OrbitHabitsWidgetProvider`, `OrbitTasksWidgetProvider` (referenced from `AndroidManifest.xml`)
- **Vault MethodChannel bridge:** `android/app/src/main/kotlin/com/poswal/orbit/MainActivity.kt`, `lib/data/vault/saf_vault_storage.dart`
- **Design Playground:** `lib/features/playground/**`
