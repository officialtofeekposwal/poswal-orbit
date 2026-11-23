# 📜 Changelog

All notable changes to **Poswal Orbit** will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0+1] - 2026-11-23

### 🎨 Unslop Design & Copy Polish Pass
- **Strict Sentence Case Across All Languages:**
  - Removed all `.toUpperCase()` invocations on user-facing copy. Standardized headers, stat cards, date formats, and sheet titles to calm sentence case ("Consistency heatmap", "Weekly performance", "Current streak", "Due date and time", "Subtasks", "Linked habit", "Record progress", "November 2026").
- **Emoji Removal & Native Icon Preservation:**
  - Removed all decorative emojis (`🌟`, `🔥`, `💡`, `🚨`, `🚀`) from UI, share strings, and notification payloads across English, Hindi, and Urdu.
  - Added native `PhosphorIconsFill.flame` icon alongside streak count in `HabitRowCard` to ensure streak signal is preserved without relying on emojis.
- **Calm, Exclamation-Free Tone:**
  - Removed exclamation marks from all ARB copy in English, Hindi, and Urdu, replacing shouty phrasing with calm, warm, and natural rewrites.
- **Localized Notification Scheduling:**
  - Localized task priority prefixes and habit notification strings in `NotificationScheduleEngine` using `AppLocalizations` (`notificationUrgentPrefix`, `notificationHighPrefix`, `notificationHabitTitle`, `notificationKeepMomentum`, `notificationTaskDueNow`), removing hardcoded English and emoji prefixes.
- **Strict Text Token Hierarchy & Contrast Separation:**
  - Resolved light-mode hierarchy inversion where secondary text had higher contrast than muted text.
  - Established strict descending contrast ladder on all surfaces: `Primary > Muted > Secondary` (Light: 18.93:1 > 7.58:1 > 5.75:1; Dark: 15.70:1 > 11.31:1 > 6.55:1; OLED: 19.63:1 > 14.14:1 > 8.19:1), with all tiers exceeding WCAG AA (>= 4.5:1) and separated by >= 1.0:1-2.0:1 contrast distance.
  - Added automated test in `wcag_contrast_audit_test.dart` to prevent contrast hierarchy regression.
- **Grid Alignment & Reduced Motion:**
  - Replaced off-grid 3px values in `habit_heatmap`, `habit_row_card`, `task_row_card`, and `settings_screen` with design tokens (`PoswalSpacing.xxs` 2px / `PoswalSpacing.xs` 4px).
  - Added `MediaQuery.disableAnimations` support in `AuroraBackground` (stops animation ticker and renders static aurora) and `PoswalOrbitRing` (snaps directly to target progress without tween).
  - Added dedicated widget tests in `reduced_motion_widgets_test.dart` asserting static rendering when animations are disabled.
- **Comprehensive Localization Scanner:**
  - Extended recursive regex audit in `localization_audit_test.dart` to verify that `label:`, `semanticLabel:`, `SnackBar`, and tooltips across `lib/` are free from raw literals, emojis, exclamations, and ALL-CAPS strings.
- **Native & Widget Localization across en, hi, and ur:**
  - Localized notification action buttons ("Mark done" / "Snooze 10m") in `NotificationService` and `NotificationScheduleEngine` using `AppLocalizations` (`notificationActionMarkDone`, `notificationActionSnooze10m`).
  - Extracted all Android widget strings from layout XML and Kotlin providers into `res/values/strings.xml`, `res/values-hi/strings.xml`, and `res/values-ur/strings.xml`.
  - Added localized string bundles for iOS widget in `ios/OrbitWidget/en.lproj`, `hi.lproj`, and `ur.lproj`.
- **High-Contrast Token Hierarchy & Separation:**
  - Fixed high-contrast token collision: added `textSecondaryHighContrastDark` (`#E2E8F0`, 13.62:1) and refined `textMutedHighContrastLight` (`#1E293B`, 13.98:1).
  - Extended `wcag_contrast_audit_test.dart` to assert that high-contrast tokens strictly exceed normal tokens at every tier (`Primary > Muted > Secondary`) and achieve WCAG AAA (>= 7.0:1) across all surfaces.
- **Background Notification Language Persistence & Immediate Regeneration:**
  - Persisted user language preference in Drift database (`AppSettingsTable`, key `app_language`), enabling background isolates, boot receivers, and daily rolling window refills to respect user language with no UI running.
  - Wired `SettingsNotifier.updateLanguage` to immediately regenerate scheduled notification triggers upon language change.

---

## [1.0.0] - 2026-11-22

### 🎉 Initial Public Open Source Release

Poswal Orbit is a calm, beautiful, and strictly offline-first habit tracker, to-do list, and private notes application built with Flutter, Drift SQLite, and Riverpod.

### 🌟 Added
- **Liquid Glass Design System (Phase 1):**
  - Custom design tokens in `poswal_tokens.dart` featuring calm aurora gradients, frosted surfaces, and WCAG AA contrast.
  - Reusable glass UI components: `AppGlass`, `AppGlassButton`, `AppGlassCard`, `AppGlassChip`, `PoswalOrbitRing`.
  - Signature 4:00 AM day-boundary logic (`DateBoundary`) ensuring night-owl habit check-ins register correctly.
- **Habits Engine & Tracking (Phase 2):**
  - Flexible schedule patterns: Daily, Specific Days of Week, and Every N Days intervals (`ScheduleEngine`).
  - Score algorithm ($0-100\%$) and streak calculations with forgiveness rules (`StreakEngine`, `HabitScoreEngine`).
  - Tactile interactive check-off rings with animated micro-interactions and haptics.
  - Detail screen with habit history, month heatmap, and scheduling preferences.
- **Task & Project Management (Phase 3A):**
  - Task organization with visual priority badges (Urgent, High, Medium, Low, None).
  - Subtasks hierarchy support with completion tracking.
  - Swipe-to-complete (right) and swipe-to-delete with 4-second undo action (left).
  - Project groups and tag filters.
- **Markdown Notes & Journaling (Phase 3B):**
  - Masonry grid layout with pinned notes section and color labels.
  - Full-screen note editor with floating glass formatting toolbar (headings, bold, italic, checklists, bullet lists).
  - Live interactive checklist toggle directly in previews and editor.
  - RTL text support for Urdu/Arabic with automatic paragraph direction detection (`MarkdownLite`).
  - Direct note-to-habit and note-to-task bidirectional chip linking.
  - Debounced auto-save on edit and app pause.
- **Data Safety & Backup Infrastructure (Phase 4A):**
  - Atomic, write-then-rename local database backups (`DataSafetyService`).
  - Rolling 7-day automated backup rotation on app launch.
  - Full JSON snapshot export and transactional restore with pre-wipe safety backups.
  - CSV export for habits, tasks, and notes.
  - One-click import compatibility with Loop Habit Tracker CSV exports.
- **Local Notifications & Reminders (Phase 4B):**
  - Exact habit reminders scheduled via `flutter_local_notifications`.
  - Background reboot rescheduling via `RECEIVE_BOOT_COMPLETED`.
  - Diagnostic Reminders Health Check screen to troubleshoot battery optimization and exact alarm permissions.
- **Insights & Localization (Phase 5A):**
  - Weekly review card with habit momentum, streak highlights, and encouraging metrics.
  - Mathematical productivity score and habit-vs-task correlation engine.
  - Clean stats card export as PNG via system share sheet.
  - Full multi-language support in English (`en`), Hindi (`hi`), and Urdu (`ur` RTL).
- **Android Home Widgets (Phase 5B):**
  - 3 native Android AppWidgets (Kotlin & XML): Today Orbit Progress Ring, Habit Check-off Widget, and Task List Widget.
- **Quality, Accessibility & Release Engineering (Phase 6):**
  - Transactional SQLite migrations with `SAVEPOINT` rollback, metadata inspection (`PRAGMA table_info`, `sqlite_master`), and pre-migration `.bak` copies.
  - Screen reader accessibility semantics (`Semantics`) on all interactive rings, tabs, toolbars, action buttons, and switches with minimum $44\times 44$ tap targets.
  - Apple Human Interface Guidelines redesign (Gates H1-H3): concentric radii, inset modal sheets (`AppSheet`), floating tab bar (`AppTabBar`), top trailing action toolbar, inline expandable multi-entity search, and light-mode accessible tokens (`tealLight`, `successLight`, `warningLight`, `dangerLight`, `violetLight`).
  - Automated GitHub Actions CI workflow for test validation and Ubuntu debug APK builds.
  - Release workflow (`.github/workflows/release.yml`) for tag-triggered signed release APK & AAB generation.
