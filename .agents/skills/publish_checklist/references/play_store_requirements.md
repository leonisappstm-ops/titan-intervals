# Google Play Store Requirements Reference

This document provides exact technical specifications, policy guidelines, and mandatory assets required for publishing Android applications on Google Play.

---

## 1. Graphic Assets & Store Listing Specifications

All graphic assets must strictly adhere to the following dimensions and format specifications. Upload them in **Google Play Console** > **Grow** > **Store presence** > **Main store listing**.

| Asset | Dimensions | Format | Max File Size | Requirements & Guidelines |
| :--- | :--- | :--- | :--- | :--- |
| **App Icon** | 512 x 512 px | 32-bit PNG | 1 MB | Full square, opaque background (no alpha transparency). Google Play applies rounded corners automatically. |
| **Feature Graphic** | 1024 x 500 px | JPEG or 24-bit PNG | 15 MB | No transparency. Avoid text clutter and border edges. Displayed as banner in Store search and top of listing. |
| **Phone Screenshots** | Min 2, Max 8 per listing | JPEG or 24-bit PNG | 8 MB each | Minimum dimension: 320 px. Maximum dimension: 3840 px. Aspect ratio: 16:9 or 9:16. Must accurately depict real in-app UI. |
| **7-inch Tablet Screenshots** *(Optional)* | Min 1, Max 8 | JPEG or 24-bit PNG | 8 MB each | Required to earn tablet badge in Store if tablet support is claimed. |
| **10-inch Tablet Screenshots** *(Optional)* | Min 1, Max 8 | JPEG or 24-bit PNG | 8 MB each | Recommended for large screen compatibility. |

---

## 2. Text Metadata & Character Limits

| Field | Max Characters | Description & Best Practices |
| :--- | :--- | :--- |
| **App Name** | 30 characters | Clear, recognizable name (e.g., *Gym Interval Timer - HIIT Tabata*). Avoid promotional phrases like "Free", "#1", or all-caps spam. |
| **Short Description** | 80 characters | High-converting single sentence summarizing the app's core utility. First text seen by users in the store app. |
| **Full Description** | 4000 characters | Detailed explanation of features, timer modes, customization options, and user benefits. Avoid repetitive keyword stuffing. |

---

## 3. Privacy Policy Requirements

- **Mandatory Requirement**: If your app accesses the internet, shows ads (AdMob), or collects any user/device data, a publicly accessible Privacy Policy is **strictly required**.
- **Hosting Options**: GitHub Pages, personal website, Notion public page, Google Sites.
- **Must Include**:
  - Entity/developer name and contact info.
  - Types of data collected (e.g., advertising identifiers, crash reports).
  - Third-party SDKs used (e.g., Google Mobile Ads SDK / AdMob).
  - Cookie / tracking disclosures and user rights under GDPR/CCPA.

---

## 4. Google Play Console Policy Questionnaires

Navigate to **Policy and programs** > **App content** in the Google Play Console:

### A. Privacy Policy
- Provide the active HTTPS URL where your policy is hosted.

### B. Advertising (Ads)
- Select **"Yes, my app contains ads"** if Google Mobile Ads / AdMob or any ad network is included in code.

### C. App Access
- If users can use all features without account registration, select: **"All functionality is available without special access"**.
- If login is required, provide test account credentials.

### D. Content Ratings (IARC)
- Complete the questionnaire. For utility apps (like timer, calculator, notes), mark "No" to violence, sexual content, profanity, and location sharing. This results in PEGI 3 / Everyone rating.

### E. Target Audience and Content (COPPA)
- Target age groups: Select adult/general audience (e.g. 18+ or 13+).
- **Caution**: Selecting children under 13 triggers Google's Designed for Families policy, requiring child-safe ad networks and extreme restrictions.

### F. Data Safety
- Even if your app doesn't collect user accounts:
  - AdMob collects **Device or other IDs** for advertising and analytics.
  - Declare data collection for `Device or other IDs`:
    - Collected? Yes.
    - Shared with third parties? Yes (Google AdMob).
    - Encrypted in transit? Yes (HTTPS).
    - Can users request deletion? Depending on AdMob policy.

---

## 5. Account Requirements & The 20-Tester Rule

### Personal Developer Accounts (Created after November 13, 2023)
- **Mandatory Closed Testing**:
  1. Set up a **Closed Testing** track.
  2. Opt in at least **20 unique testers**.
  3. Testers must remain opted-in for at least **14 consecutive days**.
  4. After 14 days, you can submit an application for **Production Access** in Play Console.

### Organization Accounts
- Organization accounts do not require the 20-tester rule and can proceed directly to production review after identity verification (requires D-U-N-S number).

---

## 6. Android Target SDK Policy

- Google Play requires all new apps and updates to target **Android 14 (API level 34)** or higher.
- Ensure `targetSdk = 34` (or `35`) in `android/app/build.gradle.kts`.
