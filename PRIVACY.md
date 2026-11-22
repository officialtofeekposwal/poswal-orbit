# 🛡️ Privacy Policy for Poswal Orbit

**Effective Date:** November 22, 2026  
**Last Updated:** November 22, 2026  

Poswal Orbit is built on a simple, uncompromising foundation: **Your data belongs to you, and only you.**

---

## 🔒 1. 100% Offline by Architecture
- **Zero Network Permissions:** Poswal Orbit does not request or possess the Android `android.permission.INTERNET` permission. The operating system strictly prevents the app from opening sockets, transmitting network packets, or accessing the internet.
- **Zero Analytics or Telemetry:** There are no analytics libraries (e.g. Firebase, Mixpanel, Google Analytics, Sentry), ad networks, tracking SDKs, or crash uploaders included in the application.
- **Zero Accounts or Cloud Storage:** You do not need to register an account, log in, or provide an email address. All your habits, tasks, entries, and notes are stored strictly in a local SQLite database (`poswal_orbit.sqlite`) inside your device's sandboxed storage.

---

## 🗄️ 2. Data Storage & Safety Backups
- **Local Storage:** All application data is stored in the local application documents directory on your physical device.
- **Automated Local Backups:** The app creates rolling 7-day encrypted/plaintext snapshots locally on your device for disaster recovery. Backups never leave your device unless you explicitly share them using your operating system's native Share Sheet.
- **Export & Import:** Full JSON and CSV exports are generated locally and written to your selected storage location. You maintain 100% custody and control of your files at all times.

---

## 📱 3. Permissions Used
| Permission | Purpose |
| :--- | :--- |
| `POST_NOTIFICATIONS` | Displays local scheduled habit reminders on your device. |
| `SCHEDULE_EXACT_ALARM` | Triggers exact local reminders at user-configured times. |
| `RECEIVE_BOOT_COMPLETED`| Reschedules active reminders locally after device reboot. |
| `VIBRATE` | Provides tactile haptic feedback during gestures and check-offs. |

---

## 🤝 5. Open Source Auditability
Poswal Orbit is open-source software licensed under the MIT License. Anyone can inspect, build, and verify the source code and dependencies to confirm that zero tracking, telemetry, or network communication exists:
[https://github.com/officialtofeekposwal/poswal-orbit](https://github.com/officialtofeekposwal/poswal-orbit)

---

## 📬 6. Contact
If you have any questions regarding this Privacy Policy, please open an issue on the GitHub repository or contact:  
**Developer:** Tofeek Poswal  
**GitHub:** `officialtofeekposwal`  
**Email:** `workwithtofeek@gmail.com`
