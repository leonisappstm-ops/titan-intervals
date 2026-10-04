# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Play Core (suppresses warnings for optional deferred components)
-dontwarn com.google.android.play.core.**

# WorkManager & Room Database
# Prevents R8 from stripping WorkManager and Room _Impl classes needed at startup (used by Google Mobile Ads SDK)
-keep class androidx.work.** { *; }
-keep class androidx.work.impl.** { *; }
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker { *; }
-keep class * extends androidx.room.RoomDatabase { *; }
-keep class **_Impl { *; }
-dontwarn androidx.work.impl.**
-dontwarn androidx.work.**
-dontwarn androidx.room.**

# Google Mobile Ads SDK
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.ads.**
-dontwarn com.google.android.gms.**

# Google Sign In & Play Services
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.gms.common.** { *; }


