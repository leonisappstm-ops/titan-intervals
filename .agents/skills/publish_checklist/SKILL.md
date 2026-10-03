---
name: publish_checklist
description: >-
  Audits and verifies all technical and administrative requirements needed to publish an Android or Flutter application to the Google Play Store.
  Use this skill whenever the user asks: "ce mai este de facut pentru a publica", "check publish readiness", "verify android release checklist", "prepare app for play store", or wants an audit of remaining launch tasks.
---

# Android & Flutter Play Store Publish Checklist

This skill guides the agent and developer through a thorough, end-to-end audit of what remains to be completed before an Android application (Flutter or native Android) can be published to Google Play Store.

## Audit Workflow

Follow these steps sequentially to audit the project and report pending tasks:

```
+-------------------------------------------------------------+
| 1. Run Automated Scan (.agents/.../check_readiness.ps1)     |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
| 2. Deep-Dive Inspection (Code, Signing, Ads, Permissions)   |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
| 3. Store Listing & Compliance Audit (Assets, Privacy, IARC) |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
| 4. Build & AAB Verification (flutter build appbundle)       |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
| 5. Output Prioritized Action Plan & Status Report           |
+-------------------------------------------------------------+
```

---

## Step 1: Run the Automated Scanner

Run the included PowerShell audit script from the project root:

```powershell
powershell -ExecutionPolicy Bypass -File .agents/skills/publish_checklist/scripts/check_readiness.ps1
```

The script automatically verifies:
- App label / Human-readable name
- Application ID / Namespace (ensures no `com.example.*` placeholder)
- Version code and version name in `pubspec.yaml`
- `key.properties` presence and `.gitignore` protection
- Gradle signing configuration (`release` block vs `debug`)
- AdMob App ID and Ad Unit IDs (flags Google test IDs: `ca-app-pub-3940256099942544...`)
- Launcher icons
- Manifest permissions
- Existing release bundle (`.aab`)

---

## Step 2: In-Depth Technical Verification

Check the following files manually to verify items requiring contextual judgment:

### 1. App Identity & Labels
- **File**: `android/app/src/main/AndroidManifest.xml`
  - Verify `android:label`: Must be the user-facing title (e.g., `"Gym Interval Timer"`, not snake_case like `"gym_interval_timer"`).
- **File**: `android/app/build.gradle.kts` (or `build.gradle`)
  - Verify `applicationId`: Must be unique and permanent (cannot be changed after first Play Store upload).
  - Verify `targetSdk`: Must meet Google Play minimums (currently API 34+).

### 2. Signing Keystore Configuration
- Check if `android/key.properties` exists.
- Check `android/app/build.gradle.kts`:
  - Ensure `signingConfigs.create("release")` loads from `key.properties`.
  - Ensure `buildTypes.release.signingConfig` uses `signingConfigs.getByName("release")` instead of `signingConfigs.getByName("debug")`.
- If missing, refer to: [Signing Setup Guide](./references/signing_setup_guide.md).

### 3. Monetization & AdMob Credentials
- **File**: `android/app/src/main/AndroidManifest.xml`
  - Ensure `com.google.android.gms.ads.APPLICATION_ID` has the real production ID, not the test ID `ca-app-pub-3940256099942544~3347511713`.
- **File**: `lib/constants/ad_constants.dart` (or ad service files)
  - Ensure `useTestAds` is switched to `false` for production release.
  - Ensure production Ad Unit IDs are replaced with live AdMob unit IDs.

### 4. Code Quality & Flutter Lints
Run static analysis and tests:
```powershell
flutter analyze
flutter test
```
Resolve any linter warnings or failing test cases before building the release bundle.

---

## Step 3: Google Play Store Assets & Compliance Audit

Verify the non-code requirements that Google Play Console enforces:

| Requirement | Specification | Status Check |
| :--- | :--- | :--- |
| **App Title** | Max 30 chars | Check store listing metadata |
| **Short Description** | Max 80 chars | High-impact summary sentence |
| **Full Description** | Max 4000 chars | Features, instructions, benefits |
| **App Icon** | 512 x 512 px PNG (max 1 MB, no alpha transparency) | Required for Play Store |
| **Feature Graphic** | 1024 x 500 px PNG/JPEG (no transparency) | Banner displayed at top of store page |
| **Screenshots** | Min 2 screenshots (phone), 16:9 or 9:16 | Real device/emulator captures |
| **Privacy Policy URL** | Publicly accessible HTTPS URL | Obligatory (AdMob collects device IDs) |
| **Closed Testing (20 testers)** | 14 consecutive days (personal accounts) | Plan tester recruitment early |

For complete specs, refer to: [Play Store Requirements](./references/play_store_requirements.md).

---

## Step 4: Release Build Verification

Test compile the Android App Bundle:
```powershell
flutter clean
flutter pub get
flutter build appbundle --release
```

Verify that the output bundle was created:
- Path: `build/app/outputs/bundle/release/app-release.aab`
- Check file size (typically under 30-50 MB for Flutter apps, hard limit 150-200 MB).

---

## Step 5: Deliver the Report

Generate a clear, formatted summary for the user using the template in:
[Checklist Report Template](./references/checklist_report_template.md).

Categorize all items into:
1. **✅ Completat (Ready)**: Items already verified and properly configured.
2. **⚠️ De Configurat în Cod (Code / Build Actions Required)**: Exact files, line numbers, and changes needed.
3. **📋 De Pregătit pentru Consola Google Play (Console & Store Assets)**: Materials, graphics, privacy policy, testing steps.
