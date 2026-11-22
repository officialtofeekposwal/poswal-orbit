# 🚀 Poswal Orbit Releasing Guide

This guide walks through creating release keystores, configuring GitHub Secrets, and deploying signed Android APKs and Google Play App Bundles (AAB) via GitHub Actions.

---

## 🔐 1. Generating Android Release Keystore (Windows)

Open PowerShell or Command Prompt on your computer and run:

```powershell
keytool -genkeypair -v -keystore poswal_orbit_release.jks -alias poswal_orbit_key -keyalg RSA -keysize 2048 -validity 10000
```

You will be prompted for:
1. Keystore password (choose a strong password).
2. Key password.
3. Your developer details (Name, Organization, Country code).

> [!CAUTION]
> **Backup your keystore file safely!** If you lose this `.jks` file or its password, you will permanently lose the ability to update your application on Google Play.
> Never commit `poswal_orbit_release.jks` or `key.properties` to version control. They are strictly ignored in `.gitignore`.

---

## 🔏 2. Base64 Encoding for GitHub Secrets

To allow GitHub Actions to securely sign the release APK and AAB without storing the binary file in the repo:

### In PowerShell (Windows):
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("poswal_orbit_release.jks")) | Set-Clipboard
```
*(The base64 encoded string is now copied directly to your clipboard)*

---

## 🔑 3. Setting Up GitHub Repository Secrets

Go to your repository on GitHub:
**Settings** $\to$ **Secrets and variables** $\to$ **Actions** $\to$ **New repository secret**.

Add the following 4 secrets:

| Secret Name | Value |
| :--- | :--- |
| `KEYSTORE_BASE64` | The base64 string from your clipboard in Step 2 |
| `KEYSTORE_PASSWORD` | The password you entered for the keystore |
| `KEY_ALIAS` | `poswal_orbit_key` |
| `KEY_PASSWORD` | The password for the key alias |

---

## 📦 4. Triggering a Release

### Method A: Pushing a Git Tag (Recommended)
```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

GitHub Actions will automatically:
1. Check out the release tag.
2. Run `flutter test --no-test-assets` to ensure all tests pass.
3. Reconstruct the release keystore in memory.
4. Build signed `poswal-orbit-v1.0.0.apk` and `poswal-orbit-v1.0.0.aab`.
5. Create a GitHub Release and attach both files.

### Method B: Manual Workflow Dispatch
1. Open the **Actions** tab on GitHub.
2. Select **Release** workflow from the left sidebar.
3. Click **Run workflow**, enter the tag version (e.g. `v1.0.0`), and run.

---

## 💻 5. Local Testing Without Keystore

`android/app/build.gradle.kts` automatically detects if `android/key.properties` is present.
If it is absent, `flutter build apk --release` seamlessly falls back to debug signing so that open-source contributors can build and test release binaries locally without needing production secrets.
