# 🪟 Windows Setup & Troubleshooting Notes

This document captures essential troubleshooting steps and solutions encountered while building and testing **Poswal Orbit** on Windows 11.

---

## 1. Windows Smart App Control (SAC) & `impellerc.exe`

### The Issue
On Windows 11 systems where **Smart App Control (SAC)** or Windows Defender Application Control (WDAC) is active (`VerifiedAndReputablePolicyState = 1`), running `flutter test` or building native Windows assets may fail with:

```text
Flutter failed to run ".../impellerc.exe ...". An Application Control policy or security policy has blocked execution.
ProcessException: An Application Control policy has blocked this file (at ../../runtime/bin/process_win.cc:593)
```

This occurs because Flutter SDK archives downloaded from the web carry the NTFS **Zone.Identifier** alternate data stream (Mark-of-the-Web), causing Windows Security to block unsigned or newly released engine helper binaries such as `impellerc.exe`.

### Solution

#### Step A: Unblock All Flutter SDK Binaries
Open an elevated or user PowerShell terminal and run:
```powershell
Get-ChildItem -Path 'D:\flutter' -Recurse | Unblock-File
```
*(Replace `D:\flutter` with your actual Flutter installation directory).*

#### Step B: Run Unit Tests with `--no-test-assets`
When running fast headless unit and widget tests that do not require GPU shader precompilation, run:
```powershell
flutter test --no-test-assets
```
*(On CI environments such as GitHub Actions Ubuntu runners, shader compilation runs natively without this flag).*

---

## 2. Java JDK & Android SDK Toolchain

Ensure your environment variables are configured in PowerShell:
```powershell
[System.Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Users\<user>\AppData\Local\Android\Sdk", "User")
flutter config --jdk-dir "C:\Program Files\Microsoft\jdk-21.0.12.101-hotspot"
```

Accept all Android SDK licenses:
```powershell
flutter doctor --android-licenses
```

---

## 3. Physical Android Device (USB Debugging)

To run the app directly on your physical Android phone (e.g. Samsung Galaxy):
1. **Enable Developer Options**: Go to **Settings > About Phone > Software Information**, tap **Build Number** 7 times.
2. **Enable USB Debugging**: Go to **Settings > Developer Options**, enable **USB Debugging**.
3. **USB Mode**: Set USB connection mode to **File Transfer / MTP** (not charging only).
4. **Authorize PC**: When the phone prompts *"Allow USB debugging?"*, check *"Always allow from this computer"* and tap **Allow**.
5. **Verify Connection**:
   ```powershell
   adb devices -l
   flutter devices
   ```
