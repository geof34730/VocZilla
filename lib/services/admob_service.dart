
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:voczilla/core/utils/logger.dart';

class AdMobService {
  static final AdMobService instance = AdMobService._();
  AdMobService._();

  // --- Using Google's Test Ad Unit IDs for verification ---

  // Google's Test Ad Unit IDs

  static const String _androidBannerAdUnitId = 'ca-app-pub-1439580806237607/5504789998';
  static const String _androidMediumRectangleAdUnitId = 'ca-app-pub-1439580806237607/5504789998'; // <-- CREATE A NEW AD UNIT FOR THIS
  static const String _androidInterstitialAdUnitId = 'ca-app-pub-1439580806237607/8818167281';

  // TODO: Replace with your real iOS Ad Unit IDs
  static const String _iosBannerAdUnitId = 'ca-app-pub-1439580806237607/1482069910';
  static const String _iosMediumRectangleAdUnitId = 'ca-app-pub-1439580806237607/1482069910'; // <-- CREATE A NEW AD UNIT FOR THIS
  static const String _iosInterstitialAdUnitId = 'ca-app-pub-1439580806237607/7570526612';



 /* static const String _androidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _androidMediumRectangleAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Using banner for test
  static const String _androidInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
*/
  /*
  static const String _iosBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';
  static const String _iosMediumRectangleAdUnitId = 'ca-app-pub-3940256099942544/2934735716'; // Using banner for test
  static const String _iosInterstitialAdUnitId = 'ca-app-pub-3940256099942544/4411468910';
*/

  InterstitialAd? _interstitialAd;

  void initialize() {
    MobileAds.instance.initialize();
    _loadInterstitialAd();
  }

  // --- Getters for platform-specific Ad Unit IDs ---

  static String get bannerAdUnitId =>
      Platform.isAndroid ? _androidBannerAdUnitId : _iosBannerAdUnitId;

  static String get mediumRectangleAdUnitId =>
      Platform.isAndroid ? _androidMediumRectangleAdUnitId : _iosMediumRectangleAdUnitId;

  static String get interstitialAdUnitId =>
      Platform.isAndroid ? _androidInterstitialAdUnitId : _iosInterstitialAdUnitId;

  // --- Interstitial Ads ---

  void _loadInterstitialAd() {

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              _loadInterstitialAd(); // Load the next one
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              Logger.Red.log('Interstitial ad failed to show: $error');
              ad.dispose();
              _loadInterstitialAd(); // Load the next one
            },
          );
          Logger.Green.log('Interstitial ad loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          Logger.Red.log('Interstitial ad failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      Logger.Yellow.log('Interstitial ad not ready yet.');
      _loadInterstitialAd();
    }
  }
}
