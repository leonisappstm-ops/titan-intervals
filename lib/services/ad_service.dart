import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_constants.dart';

/// Service managing Google AdMob Mobile Ads lifecycle and Interstitial pre-caching.
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;
  bool _isInitialized = false;

  /// Initializes the Google Mobile Ads SDK and kicks off background ad pre-caching.
  Future<void> initialize() async {
    if (!AdConstants.isAdsEnabled) return;
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('[AdService] Google Mobile Ads SDK initialized successfully.');
      loadInterstitialAd();
    } catch (e) {
      debugPrint('[AdService] Failed to initialize Mobile Ads SDK: $e');
    }
  }

  /// Pre-caches a fullscreen interstitial ad in the background.
  void loadInterstitialAd() {
    if (!AdConstants.isAdsEnabled) return;
    if (_interstitialAd != null || _isAdLoading) return;

    _isAdLoading = true;
    final adUnitId = AdConstants.interstitialAdUnitId;

    debugPrint('[AdService] Pre-loading Interstitial Ad with unit ID: $adUnitId');

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoading = false;
          debugPrint('[AdService] Interstitial Ad loaded and cached in memory.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _isAdLoading = false;
          debugPrint('[AdService] Interstitial Ad failed to load: ${error.message} (code: ${error.code})');
        },
      ),
    );
  }

  /// Displays the pre-cached interstitial ad.
  /// Calls [onDismissed] upon user close or if the ad is unavailable, ensuring zero UX blockers.
  void showInterstitialAd({required VoidCallback onDismissed}) {
    if (!AdConstants.isAdsEnabled || _interstitialAd == null) {
      debugPrint('[AdService] No ad available or ads disabled. Proceeding directly.');
      // Pre-load for next time if not already loading
      loadInterstitialAd();
      onDismissed();
      return;
    }

    final ad = _interstitialAd!;
    _interstitialAd = null; // Clear cached reference to avoid re-show

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdService] Interstitial Ad showed fullscreen content.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdService] Interstitial Ad dismissed by athlete.');
        ad.dispose();
        onDismissed();
        loadInterstitialAd(); // Immediately pre-cache next ad
      },
      onAdFailedToShowFullScreenContent: (ad, AdError error) {
        debugPrint('[AdService] Interstitial Ad failed to show: ${error.message}');
        ad.dispose();
        onDismissed();
        loadInterstitialAd();
      },
    );

    ad.show();
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
