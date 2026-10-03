# Play Store Publishing Audit Report Template

When generating an audit report for the user, use this standardized structure:

---

# 🚀 Audit Publicare Android (Google Play Store)

**Proiect**: [Numele Proiectului]  
**Data Auditului**: YYYY-MM-DD  
**Status General**: [🟢 Gata de Lansare | 🟡 Necesită Atenție | 🔴 Acțiuni Obligatorii Neefectuate]

---

## 📊 Sumar Executiv

| Categorie | Elemente Verificate | Finalizate | Rămase de Făcut |
| :--- | :--- | :--- | :--- |
| **Identitate & Versiune** | Label, Package ID, Version | X / 3 | Y |
| **Semnare & Securitate** | Keystore, key.properties, Gradle | X / 3 | Y |
| **Monetizare & Servicii** | AdMob IDs, mod producție | X / 2 | Y |
| **Materiale Magazin** | Iconiță, Banner, Capturi, Politică | X / 5 | Y |
| **Consolă & Testare** | Cont, Chestionare, 20 testeri | X / 4 | Y |

---

## 1. 🛠️ Acțiuni Obligatorii în Cod & Configurare (Action Required)

### [ ] 1.1 Titlul Aplicației pe Ecran (`android:label`)
- **Fișier**: `android/app/src/main/AndroidManifest.xml`
- **Stare curentă**: `android:label="gym_interval_timer"`
- **Acțiune**: Modifică în numele dorit (ex: `android:label="Gym Interval Timer"`).

### [ ] 1.2 Cheia de Semnare (Keystore & `key.properties`)
- **Stare curentă**: Lipsește `android/key.properties`, iar `build.gradle.kts` folosește cheia `debug`.
- **Acțiune**:
  1. Generează keystore: `keytool -genkey -v -keystore "$HOME\upload-keystore.jks" ...`
  2. Creează `android/key.properties`.
  3. Actualizează `android/app/build.gradle.kts` cu blocul `signingConfigs.create("release")`.

### [ ] 1.3 Înlocuirea ID-urilor Google AdMob de Test
- **Fișiere**:
  - `android/app/src/main/AndroidManifest.xml`: Înlocuiește `ca-app-pub-3940256099942544~3347511713` cu ID-ul real de aplicație.
  - `lib/constants/ad_constants.dart`: Setează `useTestAds = false` și adaugă Ad Unit ID-ul real de Interstitial.

---

## 2. 🎨 Materiale de Pregătit pentru Pagina Magazinului (Store Listing)

- [ ] **Iconiță Magazin**: PNG 512 x 512 px (fără transparență, max 1 MB).
- [ ] **Grafică Explicativă (Feature Graphic)**: PNG / JPEG 1024 x 500 px.
- [ ] **Capturi de Ecran (Screenshots)**: Minim 2 capturi pe telefon (16:9 sau 9:16).
- [ ] **Texte de Prezentare**:
  - Titlu (max 30 caractere)
  - Descriere scurtă (max 80 caractere)
  - Descriere completă (max 4000 caractere)
- [ ] **Link Politică de Confidențialitate**: Pagină web publică (ex. GitHub Pages).

---

## 3. 🌐 Pași în Consola Google Play (Console Checklist)

- [ ] **Cont de Dezvoltator Activ**: Taxă $25 plătită și identitate verificată.
- [ ] **Chestionare de Conținut (App Content)**:
  - Siguranța Datelor (Data Safety): Declarare colectare identificatori dispozitiv pentru AdMob.
  - Reclame: Selectat "Yes, my app contains ads".
  - Clasificare Conținut (IARC / PEGI): Completat chestionar rating.
  - Categorie public: Adulți (evitare selecție < 13 ani dacă nu e cazul).
- [ ] **Testare Închisă (Closed Testing - dacă e cont personal)**:
  - 20 de testeri unici înscriși timp de 14 zile consecutive înainte de producție.

---

## 4. 📦 Comenzi de Rulare & Validare

```powershell
# 1. Analiză statică a codului
flutter analyze

# 2. Teste automate
flutter test

# 3. Compilare pachet producție
flutter clean
flutter pub get
flutter build appbundle --release
```
Pachetul final va fi generat la:
`build/app/outputs/bundle/release/app-release.aab`
