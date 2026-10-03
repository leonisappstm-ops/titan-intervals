# Ghid Complet: Publicarea Aplicației pe Google Play Store

Acest document conține toți pașii necesari pentru a compila, semna și publica aplicația **Gym Interval Timer** pe Google Play Store.

---

## 📋 Cuprins
1. [Cerințe Preliminare & Cont Google Play Console](#1-cerințe-preliminare--cont-google-play-console)
2. [Pregătirea Codului Aplicației (Flutter & Android)](#2-pregătirea-codului-aplicației-flutter--android)
3. [Crearea Cheii de Semnare (Keystore) & Configurare Gradle](#3-crearea-cheii-de-semnare-keystore--configurare-gradle)
4. [Compilarea Pachetului de Producție (AAB)](#4-compilarea-pachetului-de-producție-aab)
5. [Materiale Obligatorii pentru Pagina Magazinului (Store Listing)](#5-materiale-obligatorii-pentru-pagina-magazinului-store-listing)
6. [Configurarea și Lansarea în Google Play Console](#6-configurarea-și-lansarea-în-google-play-console)
7. [Cum se publică o versiune nouă (Update) în viitor](#7-cum-se-publică-o-versiune-nouă-update-în-viitor)

---

## 1. Cerințe Preliminare & Cont Google Play Console

1. **Creare cont de dezvoltator**:
   - Accesează [Google Play Console](https://play.google.com/console/signup).
   - Plătește taxa unică de **$25 USD**.
   - Finalizează verificarea identității (Google cere act de identitate și dovadă de adresă).
2. **Regula celor 20 de testeri (pentru conturi personale)**:
   - Conturile personale create după noiembrie 2023 trebuie să parcurgă o etapă obligatorie de **Testare Închisă (Closed Testing)** cu cel puțin **20 de testeri unici**, timp de **14 zile consecutive**, înainte de a putea lansa aplicația în Producție.

---

## 2. Pregătirea Codului Aplicației (Flutter & Android)

### A. Numele aplicației pe ecranul utilizatorului
Deschide fișierul `android/app/src/main/AndroidManifest.xml` și schimbă eticheta aplicației din `gym_interval_timer` în numele dorit (ex. `Gym Interval Timer`):

```xml
<application
    android:label="Gym Interval Timer"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

### B. Înlocuirea ID-urilor Google AdMob de test cu cele reale
În prezent, aplicația folosește ID-uri oficiale Google de test. Înainte de lansare:
1. Intră în [Google AdMob](https://admob.google.com/) și adaugă aplicația pentru Android.
2. Copiază **App ID-ul AdMob** (format: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`) și înlocuiește-l în `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="ca-app-pub-ID_UL_TAU_REAL~DE_APLICATIE"/>
   ```
3. Creează un bloc de reclamă de tip **Interstitial** în AdMob și copiază Ad Unit ID-ul.
4. Deschide fișierul `lib/constants/ad_constants.dart` și actualizează:
   ```dart
   /// Setează pe false pentru a folosi reclame reale:
   static const bool useTestAds = false;

   /// Adaugă Ad Unit ID-ul real generat în consola AdMob:
   static const String productionInterstitialAdUnitId = 'ca-app-pub-ID_UL_TAU_REAL/UNIT_ID';
   ```

### C. Versiunea aplicației în `pubspec.yaml`
Asigură-te că versiunea din `pubspec.yaml` este setată:
```yaml
version: 1.0.0+1
```
- `1.0.0` = Numele versiunii afișat utilizatorilor (`versionName`).
- `1` = Codul versiunii intern pentru Android (`versionCode`). La fiecare lansare nouă, numărul de după `+` trebuie crescut (ex: `1.0.1+2`).

---

## 3. Crearea Cheii de Semnare (Keystore) & Configurare Gradle

Google Play acceptă doar pachete semnate cu o cheie privată criptografică.

### Pasul 1: Generează cheia Keystore
Deschide PowerShell și rulează comanda de mai jos (înlocuiește calea dacă dorești să o salvezi în alt loc sigur):

```powershell
keytool -genkey -v -keystore "C:\Users\adiym\upload-keystore.jks" -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
> ⚠️ **ATENȚIE MAXIMĂ**: Notează-ți parola aleasă și păstrează fișierul `upload-keystore.jks` pe un stick sau backup securizat. Dacă pierzi această cheie, nu vei mai putea actualiza niciodată aplicația pe Play Store!

### Pasul 2: Creează fișierul `key.properties`
Creează fișierul `android/key.properties` cu conținutul:
```properties
storePassword=PAROLA_ALEASA_PENTRU_KEYSTORE
keyPassword=PAROLA_ALEASA_PENTRU_ALIAS
keyAlias=upload
storeFile=C:\\Users\\adiym\\upload-keystore.jks
```

### Pasul 3: Protejează cheia în `.gitignore`
Deschide `.gitignore` din rădăcina proiectului și adaugă la sfârșit:
```gitignore
# Keystore & Signing credentials
*.jks
*.keystore
key.properties
```

### Pasul 4: Configurează semnarea în `android/app/build.gradle.kts`
Proiectul tău folosește Kotlin DSL. Deschide `android/app/build.gradle.kts` și adaugă configurarea de release:

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

## 4. Compilarea Pachetului de Producție (AAB)

Pentru a compila fișierul final cerut de Google Play:

1. Curăță fișierele vechi:
   ```powershell
   flutter clean
   flutter pub get
   ```
2. Compilează fișierul **App Bundle**:
   ```powershell
   flutter build appbundle --release
   ```

Pachetul generat se va afla la:
📁 `build/app/outputs/bundle/release/app-release.aab`

*(Acesta este singurul fișier pe care îl vei încărca pe Play Console).*

---

## 5. Materiale Obligatorii pentru Pagina Magazinului (Store Listing)

Înainte de a trimite aplicația, pregătește următoarele fișiere:

| Element | Format & Dimensiuni | Descriere |
| :--- | :--- | :--- |
| **Nume aplicație** | Text (max. 30 caractere) | Ex: *Gym Interval Timer - HIIT Tabata* |
| **Descriere scurtă** | Text (max. 80 caractere) | O propoziție de impact |
| **Descriere completă** | Text (până la 4000 caractere) | Funcționalități, moduri de lucru, beneficii |
| **Politica de confidențialitate** | URL public (ex. GitHub Pages / Notion) | Obligatorie deoarece folosești internet și AdMob |
| **Iconiță aplicație** | PNG 512 x 512 px (max 1 MB, fundal opac) | Logo-ul clar al aplicației |
| **Grafică explicativă (Feature Graphic)** | PNG/JPEG 1024 x 500 px (fără transparență) | Banner-ul afișat în capul paginii din Store |
| **Capturi de ecran telefon** | PNG/JPEG, minim 2 imagini | Capturi cu ecranele principale (ex: timer, setări) |

---

## 6. Configurarea și Lansarea în Google Play Console

### Pasul 1: Crearea Aplicației
1. În Google Play Console, apasă butonul **Create app**.
2. Introdu numele aplicației, limba implicită, bifează **App** (aplicație) și **Free** (gratuită).
3. Acceptă declarațiile de conformitate.

### Pasul 2: Conținutul Aplicației (App Content)
În meniul din stânga, mergi la **Policy and programs** > **App content** și completează fiecare secțiune:
- **Privacy Policy**: Introdu linkul către politica ta de confidențialitate.
- **Ads**: Bifează `Yes, my app contains ads` (deoarece folosești Google AdMob).
- **App access**: Bifează `All functionality is available without special access` (aplicația ta nu necesită autentificare/login).
- **Content ratings**: Răspunde la chestionar (indică faptul că nu conține violență, limbaj vulgar etc. -> vei primi rating 3+ sau PEGI 3).
- **Target audience**: Selectează categoriile de vârstă (ex. 18+ sau adulți; evită selectarea copiilor sub 13 ani pentru a nu intra sub incidența cerințelor stricte COPPA).
- **Data safety (Siguranța datelor)**:
  - Aplicația în sine nu colectează date personale, dar SDK-ul Google Mobile Ads colectează identificatori de dispozitiv (`Device or other IDs`) în scop de publicitate și analiză. Menționează că datele sunt criptate în tranzit.

### Pasul 3: Încărcarea pachetului AAB în Testare Închisă (Closed Testing)
1. Mergi la **Testing** > **Closed testing**.
2. Apasă pe **Create track** sau folosește canalul implicit **Alpha**.
3. Apasă pe **Create new release**.
4. Trage fișierul `build/app/outputs/bundle/release/app-release.aab`.
5. Adaugă **Release notes** (ex. `Versiunea inițială a aplicației Gym Interval Timer`).
6. Salvează și revizuiește versiunea (**Review and rollout**).

### Pasul 4: Etapa de 14 zile de Testare Închisă (dacă ai cont personal)
1. În secțiunea **Testers**, creează o listă de e-mailuri cu cel puțin **20 de testeri** (prieteni, cunoscuți).
2. Trimite-le linkul de înscriere generat de Google Play Console.
3. Testerii trebuie să descarce aplicația pe telefoanele lor și să o păstreze instalată cel puțin **14 zile consecutive**.

### Pasul 5: Solicitarea Accesului în Producție
După cele 14 zile, în consola Play Console se va activa butonul **Apply for production**. Răspunde la câteva întrebări simple despre feedback-ul primit și trimite aplicația spre revizuire.

Aprobarea Google durează de regulă între **2 și 7 zile lucrătoare**. Odată aprobată, aplicația va fi vizibilă oficial pe Magazinul Play!

---

## 7. Cum se publică o versiune nouă (Update) în viitor

Când adaugi funcționalități noi sau rezolvi bug-uri:

1. Crește versiunea în `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # +2 este noul versionCode obligatoriu mai mare
   ```
2. Rulează comanda de build:
   ```powershell
   flutter build appbundle --release
   ```
3. Mergi în Google Play Console la **Release** > **Production** (sau **Closed testing**).
4. Creează o nouă versiune (**Create release**), încarcă noul `.aab`, scrie notele noii versiuni și apasă **Start rollout to production**.
