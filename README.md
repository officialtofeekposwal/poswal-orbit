<p align="center">
  <img src="assets/brand/logo/png/poswal-orbit-lockup-horizontal-on-dark.png" alt="Poswal Orbit Logo" width="420" />
</p>

<p align="center">
  <strong>Your whole day, in orbit.</strong><br>
  <em>Habits. Tasks. Notes. One calm, beautiful place.</em>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-teal.svg" alt="License: MIT"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B.svg?logo=flutter" alt="Flutter"></a>
  <a href="https://github.com/officialtofeekposwal/poswal-orbit/actions"><img src="https://img.shields.io/github/actions/workflow/status/officialtofeekposwal/poswal-orbit/ci.yml?branch=main&label=CI" alt="CI Status"></a>
  <a href="https://github.com/officialtofeekposwal/poswal-orbit"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome"></a>
</p>

---

## 🌟 Overview

**Poswal Orbit** is an all-in-one, 100% offline-first productivity application for **iOS** and **Android**, built with Flutter. It brings daily habit tracking, task management, and markdown notes together into a unified, calm workspace rendered with a modern **Liquid Glass** aesthetic.

### Why Poswal Orbit?
- **Unified Today Screen**: Track today's habits, overdue/upcoming tasks, and pinned notes all in one glance.
- **Liquid Glass Aesthetic**: Translucent refractive surfaces floating over a soothing aurora gradient on Ink (`#070B14`), Mist (`#F4F6FB`), or true OLED Black (`#000000`).
- **Privacy First & Offline Always**: No accounts, no cloud sync required, zero analytics, zero telemetry. Your data stays on your device.
- **Streak Preservation**: Streak freezes, auto-backups, and non-destructive schedule handling so you never lose your progress.
- **Intelligent Habit Scoring**: Exponentially weighted moving average (EWMA) habit consistency scoring beyond simple streak counters.
- **Natural Language Quick Add**: Add tasks swiftly like `"Call mom tomorrow 6pm !high #family"`.

---

## 📱 Screenshots

| Today Hub (Dark) | Habits & Analytics | Tasks & Quick Add | Notes Hub |
| :---: | :---: | :---: | :---: |
| *(Coming in Phase 0)* | *(Coming in Phase 1)* | *(Coming in Phase 2)* | *(Coming in Phase 3)* |

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Impeller GPU engine enabled on iOS and Android)
- **State Management**: [Riverpod](https://riverpod.dev)
- **Local Database**: [Drift](https://drift.simonbinder.eu) (SQLite with transactional migrations)
- **Routing**: [go_router](https://pub.dev/packages/go_router)
- **Data Serialization**: [Freezed](https://pub.dev/packages/freezed) & [json_serializable](https://pub.dev/packages/json_serializable)
- **Local Notifications**: `flutter_local_notifications` + `timezone` (rolling 64-notification window)
- **Security & Privacy**: `local_auth` (Biometrics), `flutter_secure_storage`
- **Design System**: Custom `AppGlass` wrappers based on `poswal_tokens.dart` with multi-tier graceful degradation.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+ recommended)
- Android Studio with Android SDK 34+ (for Android builds)
- Xcode 15+ & CocoaPods on macOS (for iOS builds)

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/officialtofeekposwal/poswal-orbit.git
   cd poswal-orbit
   ```

2. **Verify your development environment:**
   ```bash
   flutter doctor
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run code generation (models & database):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Launch the application:**
   ```bash
   flutter run
   ```

---

## 🗺️ Project Roadmap

- [ ] **Phase 0: Foundation & Look** — Project setup, design tokens, aurora background, glass wrappers, and Design Playground screen.
- [ ] **Phase 1: Habits Core & Today Hub** — Drift database, habit engines (numeric, duration, quit), EWMA scores, and Today progress ring.
- [ ] **Phase 2: Tasks System** — Smart lists, priorities, subtasks, recurrence rules, and live NLP quick-add.
- [ ] **Phase 3: Notes & Global Search** — Markdown-lite notes editor, pins, color tags, and full-text search.
- [ ] **Phase 4: Notifications & Data Safety** — Battery-safe notifications, reminders health check, auto-backups, and CSV/JSON import-export.
- [ ] **Phase 5: Insights, Widgets & Localization** — Visual habit heatmaps, Home screen widgets, and multilingual support (English, Hindi, Urdu RTL).
- [ ] **Phase 6: Polish & Release** — Multi-device profiling, accessibility audit, and production store builds.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) and adhere to our [Code of Conduct](CODE_OF_CONDUCT.md).

---

## 📜 Third-Party Licenses & Credits

- **Fonts**:
  - [Plus Jakarta Sans](https://github.com/tokotype/PlusJakartaSans) by Tokotype (SIL Open Font License 1.1)
  - [Inter](https://github.com/rsms/inter) by Rasmus Andersson (SIL Open Font License 1.1)
  - [Noto Sans](https://fonts.google.com/noto) by Google Fonts (SIL Open Font License 1.1)
- **Icons**: Designed with inspiration from [Phosphor Icons](https://phosphoricons.com) and [Lucide Icons](https://lucide.dev).
- **Core Principles**: Inspired by community open-source trackers including Habo, Loop Habit Tracker, and Table Habit.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) © 2026 Poswal Orbit contributors.
