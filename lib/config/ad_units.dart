import 'dart:io';


// Utilisation des IDs de VocZilla

const String androidBannerAdUnitId = 'ca-app-pub-1439580806237607/5504789998';
const String iosBannerAdUnitId = 'ca-app-pub-1439580806237607/1482069910';

const String androidInterstitialAdUnitId = 'ca-app-pub-1439580806237607/8818167281';
const String iosInterstitialAdUnitId = 'ca-app-pub-1439580806237607/7570526612';


// Utilisation des IDs de test officiels de Google
/*
const String androidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
const String iosBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';

const String androidInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
const String iosInterstitialAdUnitId = 'ca-app-pub-3940256099942544/4411468910';
*/
final Map<String, String> bannerAdUnitIds = {
  'home_top': Platform.isAndroid ? androidBannerAdUnitId : iosBannerAdUnitId,
  'home_bottom': Platform.isAndroid ? androidBannerAdUnitId : iosBannerAdUnitId,
  'quizz_top': Platform.isAndroid ? androidBannerAdUnitId : iosBannerAdUnitId,
  'quizz_bottom': Platform.isAndroid ? androidBannerAdUnitId : iosBannerAdUnitId,
  'dictation_top': Platform.isAndroid ? androidBannerAdUnitId : iosBannerAdUnitId,
  'dictation_bottom': Platform.isAndroid ? androidBannerAdUnitId : iosBannerAdUnitId,
  'list_top': Platform.isAndroid ? androidBannerAdUnitId : iosBannerAdUnitId,
  'list_bottom': Platform.isAndroid ? androidBannerAdUnitId : iosBannerAdUnitId,
  'learn_top': Platform.isAndroid ? androidBannerAdUnitId : iosBannerAdUnitId,
  'learn_bottom': Platform.isAndroid ? androidBannerAdUnitId : iosBannerAdUnitId,
  'prononciation_top': Platform.isAndroid ? androidBannerAdUnitId : iosBannerAdUnitId,
  'prononciation_bottom': Platform.isAndroid ? androidBannerAdUnitId : iosBannerAdUnitId,





};

String get interstitialAdUnitId => Platform.isAndroid ? androidInterstitialAdUnitId : iosInterstitialAdUnitId;
