import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:voczilla/core/utils/logger.dart';

class AdMobService {
  static final AdMobService instance = AdMobService._();
  AdMobService._();

  // --- Gate global pubs ---
  bool _adsEnabled = true; // mets à false pour les abonnés
  bool get adsEnabled => _adsEnabled;

  // --- Init SDK ---
  bool _initialized = false;

  // --- Home Screen Banner Ads (2 emplacements) ---
  BannerAd? bannerAd1;
  final ValueNotifier<bool> isBannerAd1Loaded = ValueNotifier(false);

  BannerAd? bannerAd2;
  final ValueNotifier<bool> isBannerAd2Loaded = ValueNotifier(false);

  bool _homeScreenAdsLoading = false;
  double? _lastHomeWidthPx; // pour éviter de recharger si la largeur n’a pas changé

  // --- Ad Unit IDs ---
  static const String _androidBannerAdUnitId = 'ca-app-pub-1439580806237607/5504789998';
  static const String _androidInterstitialAdUnitId = 'ca-app-pub-1439580806237607/8818167281';
  static const String _iosBannerAdUnitId = 'ca-app-pub-1439580806237607/1482069910';
  static const String _iosInterstitialAdUnitId = 'ca-app-pub-1439580806237607/7570526612';

  static String get bannerAdUnitId =>
      Platform.isAndroid ? _androidBannerAdUnitId : _iosBannerAdUnitId;

  static String get interstitialAdUnitId =>
      Platform.isAndroid ? _androidInterstitialAdUnitId : _iosInterstitialAdUnitId;

  // --- Interstitial ---
  InterstitialAd? _interstitialAd;
  int _interstitialRetry = 0;

  // -------------------------
  // Public API
  // -------------------------

  /// Initialise le SDK si pubs activées (à appeler tôt, ex: au boot).
  Future<void> initialize() async {
    if (!_adsEnabled) {
      Logger.Yellow.log('[Ads] initialize() ignoré: adsEnabled=false');
      return;
    }
    if (_initialized) return;

    await MobileAds.instance.initialize();
    _initialized = true;
    Logger.Green.log('[Ads] SDK initialisé');
    _loadInterstitialAd();
  }

  /// Active/Désactive *toute* la pub (appelle ceci quand l’état d’abonnement change)
  Future<void> setAdsEnabled(bool enabled) async {
    if (_adsEnabled == enabled) return;
    _adsEnabled = enabled;

    if (!enabled) {
      Logger.Yellow.log('[Ads] Désactivation complète des publicités');
      // Stop interstitial
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _interstitialRetry = 0;

      // Stop bannières
      bannerAd1?.dispose(); bannerAd1 = null;
      bannerAd2?.dispose(); bannerAd2 = null;
      isBannerAd1Loaded.value = false;
      isBannerAd2Loaded.value = false;
      _homeScreenAdsLoading = false;
      _lastHomeWidthPx = null;
      return;
    }

    Logger.Green.log('[Ads] Activation des publicités');
    // Réactive: initialise si besoin et recharge l’interstitiel
    await initialize();
    _loadInterstitialAd();
  }

  // -------------------------
  // Home banners (2 placements)
  // -------------------------

  /// Charge (ou recharge) les deux bannières du Home pour la largeur *effective* de l’écran.
  /// Ne fait rien si adsEnabled=false.
  Future<void> loadHomeScreenBannerAds(BuildContext context) async {
    if (!_adsEnabled) {
      Logger.Yellow.log('[Ads] loadHomeScreenBannerAds ignoré: adsEnabled=false');
      return;
    }
    await initialize();
    if (!_initialized) return;

    final widthPx = MediaQuery.of(context).size.width;
    if (widthPx <= 0) return;

    // Évite les reloads si la largeur n’a pas réellement changé (à 1 px près)
    final widthChanged =
        _lastHomeWidthPx == null || widthPx.round() != _lastHomeWidthPx!.round();

    if (_homeScreenAdsLoading) {
      Logger.Yellow.log('[Ads] Home banners déjà en chargement…');
      return;
    }

    // Si on a déjà deux bannières et que la largeur n’a pas changé, ne rien faire
    if (!widthChanged && bannerAd1 != null && bannerAd2 != null) {
      return;
    }

    _homeScreenAdsLoading = true;
    _lastHomeWidthPx = widthPx;

    final AnchoredAdaptiveBannerAdSize? size =
    await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(widthPx.truncate());

    if (size == null) {
      Logger.Red.log('Unable to get anchored adaptive banner ad size.');
      _homeScreenAdsLoading = false;
      return;
    }

    // (Re)charge banner 1
    if (bannerAd1 != null) {
      bannerAd1!.dispose();
      bannerAd1 = null;
      isBannerAd1Loaded.value = false;
    }
    bannerAd1 = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          Logger.Green.log('Service: Banner ad 1 loaded.');
          bannerAd1 = ad as BannerAd;
          isBannerAd1Loaded.value = true;
        },
        onAdFailedToLoad: (ad, err) {
          Logger.Red.log('Service: Banner ad 1 failed to load: ${err.code} ${err.message}');
          ad.dispose();
          isBannerAd1Loaded.value = false;
        },
      ),
    )..load();

    // (Re)charge banner 2
    if (bannerAd2 != null) {
      bannerAd2!.dispose();
      bannerAd2 = null;
      isBannerAd2Loaded.value = false;
    }
    bannerAd2 = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          Logger.Green.log('Service: Banner ad 2 loaded.');
          bannerAd2 = ad as BannerAd;
          isBannerAd2Loaded.value = true;
          _homeScreenAdsLoading = false;
        },
        onAdFailedToLoad: (ad, err) {
          Logger.Red.log('Service: Banner ad 2 failed to load: ${err.code} ${err.message}');
          ad.dispose();
          isBannerAd2Loaded.value = false;
          _homeScreenAdsLoading = false;
        },
      ),
    )..load();
  }

  // -------------------------
  // Interstitial
  // -------------------------

  void _loadInterstitialAd() {
    if (!_adsEnabled) return;
    if (!_initialized) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialRetry = 0;
          _interstitialAd = ad
            ..fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                ad.dispose();
                _interstitialAd = null;
                if (_adsEnabled) _loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
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
          // Backoff exponentiel + jitter (max ~5 min)
          final delay = Duration(
            seconds: math.min(300, (1 << _interstitialRetry)) + math.Random().nextInt(5),
          );
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
      Logger.Yellow.log('Interstitial ad not ready yet. Preloading…');
      _loadInterstitialAd();
    }
  }

  // -------------------------
  // Dispose
  // -------------------------

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;

    bannerAd1?.dispose(); bannerAd1 = null;
    bannerAd2?.dispose(); bannerAd2 = null;

    // Ne pas dispose() les ValueNotifier si d'autres widgets les écoutent encore à chaud.
    // Laisse le GC les récupérer à la fermeture de l’app, ou gère leur cycle au besoin.
    // isBannerAd1Loaded.dispose();
    // isBannerAd2Loaded.dispose();

    _initialized = false;
    _homeScreenAdsLoading = false;
    _lastHomeWidthPx = null;
    _interstitialRetry = 0;
  }
}
