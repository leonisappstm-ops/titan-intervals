# Settings, Customization & Monetization Walkthrough

## 🌟 Overview
We implemented an extensive, high-end personalization and monetization experience in **Titan Intervals**:
1. **Monetizare cu Google AdMob**: Reclame fullscreen (**Interstitial Ads**) afișate la finalizarea antrenamentului (Opțiunea B).
2. **Panouri expandabile animate (acordeon)**: Organizare compactă și modernă în ecranul de Setări.
3. **Animație cerc complet 360° la timer**: Mișcare fluidă fără oprire prematură.
4. **Teme audio specifice**: Sunete reale de ring, boluri tibetane și fluier militar.

---

## 💰 1. Monetizare Google AdMob (Fullscreen Interstitial Ads)
A fost integrat SDK-ul oficial **Google Mobile Ads (AdMob)** conform **Opțiunii B**:
- **Experiență optimă pentru utilizator (UX & Google Play Policy)**:
  - Când cronometrul ajunge la zero, atletul vede ecranul triumfător cu trofeul „WORKOUT CRUSHED!”, caloriile arse și timpul total.
  - Când atletul apasă pe **BACK TO WORKOUTS** (sau **REPEAT WORKOUT**, ori gestul de Back pe Android), se declanșează reclama fullscreen AdMob.
  - La închiderea reclamei (butonul X), navigarea continuă instant către destinația aleasă.
- **Pre-caching în fundal**:
  - Reclama este descărcată și memorată în cache automat încă de la pornirea workout-ului prin `AdService().loadInterstitialAd()`. Astfel, la finalizarea antrenamentului, reclama se deschide instantaneu, fără timp de așteptare.
  - La închiderea unei reclame, serviciul începe imediat pre-încărcarea următoarei reclame.
- **Configurare Test / Producție**:
  - În [ad_constants.dart](file:///d:/Programare/Flutter/Test/lib/constants/ad_constants.dart) sunt configurate ID-urile oficiale de test Google pentru prevenirea oricărui risc de invalid traffic în timpul dezvoltării.
  - Când dorești să publici aplicația pe Google Play Store, schimbi `useTestAds = false` și adaugi ID-ul tău real Ad Unit în `productionInterstitialAdUnitId`.

---

## ⭕ 2. Animație Cerc Complet 360° la Timer
- **Target-based Smooth Interpolation**: La fiecare secundă, `CircularTimerRing` calculează cu precizie ținta pe care o va atinge la finalul acelei secunde:
  $$\text{Target} = \frac{\text{Elapsed} + 1}{\text{Total}}$$
  În ultima secundă ($\text{Remaining} = 1$), ținta devine exact $1.0$ (100% / 360°).
- **Tranziție 360° desăvârșită**: În `_TimerRingPainter`, când progresul atinge $0.999 \to 1.0$, cercul este randat prin `canvas.drawCircle`, garantând o închidere perfectă la 360 de grade fără spații sau suprapuneri.
- **Suport Pauză / Reluare**: Animația se îngheață instant când timer-ul este pe pauză (`isPaused`) și continuă lin la reluare.

---

## 📂 3. Panouri Expandabile Animate (Acordeon Inline)
- **APP COLOR SCHEME**: Afișează tema activă (ex: `Solar Amber [ACTIVE]`), cele 3 buline de culoare din paletă și o săgeată animată chevron.
- **WORKOUT SOUND SCHEME**: Afișează tema de sunet activă (ex: `Gym Boxing Bell [ACTIVE]`), iconița dedicată și săgeata animată chevron.
- La apăsare, săgeata se rotește lin cu 180° prin `AnimatedRotation`, iar lista de opțiuni se extinde prin `AnimatedCrossFade` (280ms, curbă `fastOutSlowIn`).

---

## 🔊 4. Workout Sound Schemes & Authentic Themed Audio
1. **Gym Boxing Bell**: Clopot dublu la Work (~2s), clopot simplu la Rest (~2s), woodblock knock la numărătoarea inversă (3.. 2.. 1..).
2. **Zen Harmony**: Lovitură adâncă de bol tibetan la Work, chime meditativ la Rest, bol tibetan lung la final.
3. **Military Drill**: Dublu fluierat tactic la Work, fluierat simplu la Rest, semnal de goarnă (*First Call*) la final.

---

## 🛠️ Fișiere Noi și Modificate pentru Monetizare

- [pubspec.yaml](file:///d:/Programare/Flutter/Test/pubspec.yaml): Dependință `google_mobile_ads: ^9.1.0`.
- [AndroidManifest.xml](file:///d:/Programare/Flutter/Test/android/app/src/main/AndroidManifest.xml): Permisiuni de internet și AdMob `APPLICATION_ID`.
- [ad_constants.dart](file:///d:/Programare/Flutter/Test/lib/constants/ad_constants.dart): ID-uri de test și producție Google AdMob.
- [ad_service.dart](file:///d:/Programare/Flutter/Test/lib/services/ad_service.dart): Serviciu singleton cu pre-caching automat și callback-uri complete.
- [main.dart](file:///d:/Programare/Flutter/Test/lib/main.dart): Inițializare `AdService().initialize()` la pornire.
- [workout_complete_screen.dart](file:///d:/Programare/Flutter/Test/lib/screens/workout_complete_screen.dart): Afișare reclamă pe butoanele de `BACK TO WORKOUTS`, `REPEAT WORKOUT` și gestul de back Android (`PopScope`).
- [active_timer_screen.dart](file:///d:/Programare/Flutter/Test/lib/screens/active_timer_screen.dart): Pre-încărcare în fundal a reclamei la startul antrenamentului.
- [gradle.properties](file:///d:/Programare/Flutter/Test/android/gradle.properties): Compatibilitate `kotlin.incremental=false` pe Windows.
