import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:voczilla/config/ad_units.dart';
import 'package:voczilla/core/utils/logger.dart';

class AdMobService {
  static final AdMobService instance = AdMobService._();
  AdMobService._();

  // --- State ---
  bool _adsEnabled = true;
  bool _initialized = false;
  double? _lastKnownWidthPx;

  // --- Ad Storage ---
  final Map<String, BannerAd?> _banners = {};
  final Map<String, ValueNotifier<bool>> _bannerLoadNotifiers = {};
  final Map<String, bool> _bannerLoadingState = {};

  // --- Interstitial ---
  InterstitialAd? _interstitialAd;
  int _interstitialRetry = 0;

  // ------------------------
  // Public API
  // ------------------------

  Future<void> initialize() async {
    if (!_adsEnabled) {
      Logger.Yellow.log('[Ads] initialize() ignored: adsEnabled=false');
      return;
    }
    if (_initialized) return;

    await MobileAds.instance.initialize();
    _initialized = true;
    Logger.Green.log('[Ads] SDK initialized');
    _loadInterstitialAd();
  }

  Future<void> setAdsEnabled(bool enabled) async {
    if (_adsEnabled == enabled) return;
    _adsEnabled = enabled;

    if (enabled) {
      Logger.Green.log('[Ads] Enabling ads');
      await initialize();
      _loadInterstitialAd();
    } else {
      Logger.Yellow.log('[Ads] Disabling all ads');
      disposeAllAds();
    }
  }

  // ------------------------
  // Banner Management
  // ------------------------

  BannerAd? getBanner(String placementId) => _banners[placementId];

  ValueNotifier<bool> getBannerNotifier(String placementId) {
    return _bannerLoadNotifiers.putIfAbsent(placementId, () => ValueNotifier(false));
  }

  Future<void> loadBanner({
    required String placementId,
    required BuildContext context,
    bool forceReload = false,
  }) async {
    if (!_adsEnabled) return;
    await initialize(); // Ensure initialized
    if (!_initialized) return;

    final adUnitId = bannerAdUnitIds[placementId];
    if (adUnitId == null) {
      Logger.Red.log('No ad unit ID for placement: $placementId');
      return;
    }

    if (_bannerLoadingState[placementId] == true) return;

    final widthPx = MediaQuery.of(context).size.width;
    if (widthPx <= 0) return;

    final widthChanged = _lastKnownWidthPx == null || widthPx.round() != _lastKnownWidthPx!.round();
    _lastKnownWidthPx = widthPx;

    if (_banners[placementId] != null && !forceReload && !widthChanged) {
      return; // Ad is already loaded and size hasn't changed
    }

    _bannerLoadingState[placementId] = true;

    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(widthPx.truncate());
    if (size == null) {
      Logger.Red.log('Unable to get anchored adaptive banner ad size for $placementId.');
      _bannerLoadingState[placementId] = false;
      return;
    }

    // Dispose previous ad before loading a new one
    _banners[placementId]?.dispose();
    _banners[placementId] = null;
    getBannerNotifier(placementId).value = false;

    final ad = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          Logger.Green.log('Service: Banner ad for "$placementId" loaded.');
          _banners[placementId] = ad as BannerAd;
          getBannerNotifier(placementId).value = true;
          _bannerLoadingState[placementId] = false;
        },
        onAdFailedToLoad: (ad, err) {
          Logger.Red.log('Service: Banner ad for "$placementId" failed: ${err.code} ${err.message}');
          ad.dispose();
          getBannerNotifier(placementId).value = false;
          _bannerLoadingState[placementId] = false;
        },
      ),
    );
    await ad.load();
  }
  int _timerSecondesBannier = 1;
  /// Loads the two banners for the home screen sequentially to avoid duplicates.
  Future<void> loadHomeScreenBanners(BuildContext context) async {
    await initialize();
    loadBanner(placementId: 'home_top', context: context);
    Future.delayed( Duration(seconds: _timerSecondesBannier), () {
      if (!_adsEnabled) return;
      if(Platform.isIOS) {
        loadBanner(placementId: 'home_bottom', context: context);
      }
    });
  }

  Future<void> loadDictationScreenBanners(BuildContext context) async {
    await initialize();
    loadBanner(placementId: 'dictation_top', context: context);
    Future.delayed( Duration(seconds: _timerSecondesBannier), () {
      if (!_adsEnabled) return;
      if(Platform.isIOS) {
        loadBanner(placementId: 'dictation_bottom', context: context);
      }
    });
  }

  Future<void> loadListScreenBanners(BuildContext context) async {
    await initialize();
    loadBanner(placementId: 'list_top', context: context);
    Future.delayed( Duration(seconds: _timerSecondesBannier), () {
      if (!_adsEnabled) return;
      if(Platform.isIOS) {
        loadBanner(placementId: 'list_bottom', context: context);
      }
    });
  }
  Future<void> loadPrononciationnScreenBanners(BuildContext context) async {
    await initialize();
    loadBanner(placementId: 'prononciation_top', context: context);
    Future.delayed( Duration(seconds: _timerSecondesBannier), () {
      if (!_adsEnabled) return;
      if(Platform.isIOS) {
        loadBanner(placementId: 'prononciation_bottom', context: context);
      }
    });
  }

  Future<void> loadLearnScreenBanners(BuildContext context) async {
    await initialize();
    loadBanner(placementId: 'learn_top', context: context);
    Future.delayed( Duration(seconds: _timerSecondesBannier), () {
      if (!_adsEnabled) return;
      if(Platform.isIOS) {
        loadBanner(placementId: 'learn_bottom', context: context);
      }
    });
  }


  Future<void> loadQuizzScreenBanners(BuildContext context) async {
    await initialize();
    loadBanner(placementId: 'quizz_top', context: context);
    Future.delayed( Duration(seconds: _timerSecondesBannier), () {
      if (!_adsEnabled) return;
      if(Platform.isIOS) {
        loadBanner(placementId: 'quizz_bottom', context: context);
      }
    });
  }

  void disposeBanner(String placementId) {
    _banners[placementId]?.dispose();
    _banners.remove(placementId);
    if (_bannerLoadNotifiers.containsKey(placementId)) {
      _bannerLoadNotifiers[placementId]!.dispose();
      _bannerLoadNotifiers.remove(placementId);
    }
    _bannerLoadingState.remove(placementId);
    Logger.Green.log('[Ads] Disposed banner for "$placementId"');
  }

  void disposeDictationScreenBanners() {
    disposeBanner('dictation_top');
    if(Platform.isIOS) {
      disposeBanner('dictation_bottom');
    }
  }

  void disposePronunciationScreenBanners() {
    disposeBanner('prononciation_top');
    if(Platform.isIOS) {
      disposeBanner('prononciation_bottom');
    }
  }

  void disposeHomeScreenBanners() {
    disposeBanner('home_top');
    if(Platform.isIOS) {
      disposeBanner('home_bottom');
    }
  }

  void disposeListScreenBanners() {
    disposeBanner('list_top');
    if(Platform.isIOS) {
      disposeBanner('list_bottom');
    }
  }

  void disposeLearnScreenBanners() {
    disposeBanner('learn_top');
    if(Platform.isIOS) {
      disposeBanner('learn_bottom');
    }
  }

  void disposeQuizzScreenBanners() {
    disposeBanner('quizz_top');
    if(Platform.isIOS) {
      disposeBanner('quizz_bottom');
    }
  }

  // ------------------------
  // Interstitial Management
  // ------------------------

  void _loadInterstitialAd() {
    if (!_adsEnabled || !_initialized) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialRetry = 0;
          _interstitialAd = ad..fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              if (_adsEnabled) _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              Logger.Red.log('Interstitial show failed: $error');
              ad.dispose();
              _interstitialAd = null;
              if (_adsEnabled) _loadInterstitialAd();
            },
          );
          Logger.Green.log('Interstitial ad loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          Logger.Red.log('Interstitial ad failed to load: $error');
          _interstitialAd = null;
          if (!_adsEnabled) return;
          final delay = Duration(seconds: math.min(300, (1 << _interstitialRetry)) + math.Random().nextInt(5));
          _interstitialRetry = math.min(_interstitialRetry + 1, 9);
          Future.delayed(delay, () {
            if (_adsEnabled) _loadInterstitialAd();
          });
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (!_adsEnabled) return;
    final ad = _interstitialAd;
    if (ad != null) {
      ad.show();
    } else {
      Logger.Yellow.log('Interstitial ad not ready yet. Preloading...');
      _loadInterstitialAd();
    }
  }

  // ------------------------
  // Cleanup
  // ------------------------

  void disposeAllAds() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _interstitialRetry = 0;

    for (var ad in _banners.values) {
      ad?.dispose();
    }
    _banners.clear();
    _bannerLoadNotifiers.clear();
    _bannerLoadingState.clear();
  }

  void dispose() {
    disposeAllAds();
    _initialized = false;
  }
}
