# 📜 Changelog

All notable changes to **Poswal Orbit** will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- **Security & Android Home Widgets (Phase 5B):**
  - Biometric authentication lock (Face ID, Fingerprint, Passcode) with configurable background lock timeouts.
  - Android Recents preview blur/obscure toggle.
  - 3 native Android AppWidgets (Kotlin & XML): Today Orbit Progress Ring, Habit Check-off Widget, and Task List Widget.
- **Quality, Accessibility & Release Engineering (Phase 6):**
  - Transactional SQLite migrations with `SAVEPOINT` rollback, metadata inspection (`PRAGMA table_info`, `sqlite_master`), and pre-migration `.bak` copies.
  - Screen reader accessibility semantics (`Semantics`) on all interactive rings, tabs, FAB, and switches with minimum $44\times 44$ tap targets.
  - Automated GitHub Actions CI workflow for test validation and Ubuntu debug APK builds.
  - Release workflow (`.github/workflows/release.yml`) for tag-triggered signed release APK & AAB generation.
