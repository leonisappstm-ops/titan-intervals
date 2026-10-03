/// Centralized Google AdMob configuration and unit IDs for Titan Intervals.
class AdConstants {
  // Official Google AdMob Test App ID (Android)
  static const String testAppId = 'ca-app-pub-3940256099942544~3347511713';

  // Official Google AdMob Test Interstitial Unit ID (Android)
  static const String testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  /// Toggle to enable or disable ads globally in the app
  static const bool isAdsEnabled = true;

  /// Set to false when publishing to production with real AdMob Ad Unit ID
  static const bool useTestAds = true;

  /// Paste your real production Interstitial Ad Unit ID here when ready for Google Play release:
  static const String productionInterstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';

  /// Returns the active Interstitial Ad Unit ID based on test / production mode
  static String get interstitialAdUnitId =>
      useTestAds ? testInterstitialAdUnitId : productionInterstitialAdUnitId;
}
