/// Centralized Google AdMob configuration and unit IDs for Titan Intervals.
class AdConstants {
  // Google AdMob App ID (Android)
  static const String appId = 'ca-app-pub-1098251590095935~5196305097';

  /// Toggle to enable or disable ads globally in the app
  static const bool isAdsEnabled = true;

  /// Set to false when publishing to production with real AdMob Ad Unit ID
  static const bool useTestAds = false;

  /// Production Interstitial Ad Unit ID for Google Play release:
  static const String productionInterstitialAdUnitId = 'ca-app-pub-1098251590095935/2443906836';

  /// Returns the active Interstitial Ad Unit ID based on test / production mode
  static String get interstitialAdUnitId => productionInterstitialAdUnitId;
}
