# 🍏 Poswal Orbit: iOS Platform Status & Contributor Guide

> **Status:** Unverified on Physical Hardware / macOS Simulator (Built in Windows environment without macOS host)

---

## 🔍 Honest State Assessment

Poswal Orbit is designed and architected using cross-platform Flutter primitives, pure-Dart domain logic, standard Drift SQLite, and cross-platform plugins. However, because our primary development workstation is Windows, **iOS builds, simulators, and physical iPhone testing have not been verified locally**.

We value complete honesty with our users and open-source community: we do not claim native iOS verification until someone runs and verifies it on a Mac.

---

## 📱 Feature Expectations vs. Verification Needed

| Component | Technology | Expected Behavior | Verification Needed |
| :--- | :--- | :--- | :--- |
| **Glass UI & Visuals** | `app_glass.dart`, `BackdropFilter` | Flutter standard backdrop filters render smoothly on Metal | Check 120Hz ProMotion fluidity on iPhone 13+ Pro |
| **Database & Migrations**| `drift`, `sqlite3` | Native iOS SQLite engine with WAL journaling | Verify file migration from schema v1 $\to$ v3 on iOS sandbox |
| **Notifications** | `flutter_local_notifications` | UNUserNotificationCenter alerts and badges | Verify permission prompt and scheduled sound/haptics |
| **Haptic Feedback** | `HapticFeedback` | CoreHaptics light / medium / heavy impact | Verify iOS taptic engine triggers on ring check-off |
| **Data Safety & Backups**| `path_provider` | Sandboxed documents directory JSON snapshots | Verify Safari share sheet integration via `share_plus` |
| **Home Screen Widgets** | `home_widget` / WidgetKit | Requires Swift WidgetExtension | **Needs Implementation:** Android AppWidgets exist; iOS WidgetKit extension needs to be authored in Swift |

---

## 🤝 How Mac Contributors Can Help

If you have a Mac and an iPhone or Xcode Simulator:

1. **Clone and Install:**
   ```bash
   git clone https://github.com/officialtofeekposwal/poswal-orbit.git
   cd poswal-orbit
   flutter pub get
   cd ios && pod install && cd ..
   ```

2. **Verify Simulator Build:**
   ```bash
   flutter run -d iPhone
   ```

3. **Contribute iOS WidgetKit Extension:**
   - Author a Swift `WidgetBundle` in `ios/OrbitWidgets` utilizing App Groups to display today's habit orbit ring and task list.
   - Submit a pull request!
