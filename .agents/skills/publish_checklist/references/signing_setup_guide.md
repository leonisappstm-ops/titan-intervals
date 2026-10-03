# Android App Signing Setup Guide

Google Play requires all Android applications to be digitally signed with an upload key before they can be accepted.

---

## Step 1: Generate Upload Keystore

Run the following command in PowerShell to generate an RSA 2048-bit keystore:

```powershell
keytool -genkey -v -keystore "$HOME\upload-keystore.jks" -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

> ⚠️ **CRITICAL WARNING**:
> - Never lose your keystore file or forget the passwords!
> - Back up `upload-keystore.jks` in a secure location (e.g. encrypted cloud backup or password manager).
> - If lost, updating your existing app on Google Play Console requires a manual reset request to Google Play Developer Support.

---

## Step 2: Create `android/key.properties`

Create a file named `android/key.properties` (do not commit this to version control):

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=C:\\Users\\YOUR_USERNAME\\upload-keystore.jks
```

> **Note on Windows Paths**: Use double backslashes `\\` for file paths in `.properties` files.

---

## Step 3: Ensure Credentials are in `.gitignore`

Check that your root `.gitignore` includes:

```gitignore
*.jks
*.keystore
key.properties
```

---

## Step 4: Configure Gradle for Release Signing

### Option A: Kotlin DSL (`android/app/build.gradle.kts`)

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.gymtimer.gym_interval_timer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.gymtimer.gym_interval_timer"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

---

### Option B: Groovy DSL (`android/app/build.gradle`)

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## Step 5: Test Release Build

Compile the release bundle:

```powershell
flutter clean
flutter pub get
flutter build appbundle --release
```

Expected output path:
`build/app/outputs/bundle/release/app-release.aab`
