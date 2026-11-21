# 📱 Installing Poswal Orbit Debug APK on Samsung Galaxy M36

Since Windows 11 Smart App Control prevents local unsigned shader compilation on your PC, GitHub Actions automatically builds the identical Android debug APK on every commit and makes it available for download.

---

## Step 1: Download the APK from GitHub Actions

1. On your PC or directly on your phone's browser, go to your repository:  
   **[https://github.com/officialtofeekposwal/poswal-orbit](https://github.com/officialtofeekposwal/poswal-orbit)**
2. Click on the **Actions** tab at the top.
3. Click the most recent workflow run (e.g. `feat(notifications): ...`).
4. Scroll down to the **Artifacts** section at the bottom of the summary page.
5. Click **`poswal-orbit-debug-apk`** to download `poswal-orbit-debug-apk.zip`.
6. Extract the ZIP file to get **`app-debug.apk`**.

---

## Step 2: Transfer to Your Phone (If downloaded on PC)

- **Via USB cable**: Copy `app-debug.apk` to your phone's **Downloads** folder.
- **Via Quick Share / Telegram / WhatsApp / Google Drive**: Send the `.apk` file directly to your phone.

---

## Step 3: Enable "Install Unknown Apps" on Samsung Galaxy M36

On Samsung One UI (Android 14 / 15):
1. Open **My Files** (or **Chrome** if you downloaded it directly on the phone).
2. Tap on `app-debug.apk`.
3. A security prompt will appear: *"For your security, your phone currently isn't allowed to install unknown apps from this source"*.
4. Tap **Settings** on the prompt.
5. Turn **ON** the toggle: **"Allow from this source"**.
6. Press the **Back** button.
7. Tap **Install**.

---

## Step 4: Optimal Samsung Settings for Real Notification Testing

Samsung One UI aggressively restricts background execution to save battery. To ensure exact alarms and scheduled notifications trigger reliably:
1. Long-press the **Poswal Orbit** app icon → tap the **(i)** info icon (App info).
2. Go to **Battery** → select **"Unrestricted"** (instead of *Optimized*).
3. Go to **Permissions** → tap **Notifications** → ensure **"Allow notifications"** and **"Allow sound and vibration"** are turned **ON**.
4. Tap **Alarms & reminders** (under Advanced) → ensure **"Allow setting alarms and reminders"** is turned **ON**.
