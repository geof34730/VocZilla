/// Bibliothèque partagée pour mapper les locales du projet aux formats
/// attendus par le Google Play Store et l'App Store Connect.
/// C'est la source de vérité unique pour la logique de mappage.

// ===========================================================================
// LOGIQUE POUR APP STORE CONNECT (IOS)
// ===========================================================================

/// Mappage des locales du projet vers les locales spécifiques à Apple.
const Map<String, String> _appleLocaleMapping = {
  'en': 'en-US', 'en-GB': 'en-GB', 'en-CA': 'en-CA', 'fr': 'fr-FR', 'fr-CA': 'fr-CA',
  'es': 'es-ES', 'es-MX': 'es-MX', 'de': 'de-DE', 'it': 'it',
  'pt': 'pt-PT', // Spécifique à Apple : Portugais (Portugal)
  'pt-BR': 'pt-BR', 'zh': 'zh-Hans', 'zh-CN': 'zh-Hans', 'zh-HK': 'zh-Hant',
  'zh-TW': 'zh-Hant', 'ja': 'ja', 'ko': 'ko', 'ru': 'ru', 'ar': 'ar-SA',
  'nl': 'nl-NL', 'sv': 'sv', 'fi': 'fi', 'da': 'da', 'no': 'no', 'tr': 'tr',
  'pl': 'pl', 'id': 'id', 'th': 'th', 'vi': 'vi', 'he': 'he', 'ms': 'ms',
  'ro': 'ro', 'cs': 'cs', 'sk': 'sk', 'hr': 'hr', 'uk': 'uk', 'hi': 'hi',
  'el': 'el', 'ca': 'ca', 'et-EE': 'et', 'uk-UA': 'uk',
};

/// Liste des locales officiellement supportées par deliver/App Store Connect.
const Set<String> _appStoreSupportedLocales = {
  'ar-SA', 'ca', 'cs', 'da', 'de-DE', 'el', 'en-AU', 'en-CA', 'en-GB', 'en-US',
  'es-ES', 'es-MX', 'fi', 'fr-CA', 'fr-FR', 'he', 'hi', 'hr', 'hu', 'id', 'it',
  'ja', 'ko', 'ms', 'nl-NL', 'no', 'pl', 'pt-BR', 'pt-PT', 'ro', 'ru', 'sk',
  'sv', 'th', 'tr', 'uk', 'vi', 'zh-Hans', 'zh-Hant', 'et'
};

/// Convertit une locale du projet en sa version pour l'App Store.
String? toAppleLocale(String locale) {
  if (_appleLocaleMapping.containsKey(locale)) {
    final appleLocale = _appleLocaleMapping[locale]!;
    // Si la locale mappée est supportée, on la retourne, sinon, échec.
    return _appStoreSupportedLocales.contains(appleLocale) ? appleLocale : null;
  }
  if (_appStoreSupportedLocales.contains(locale)) return locale;
  return null; // Fallback : la locale n'est pas supportée.
}

// ===========================================================================
// LOGIQUE POUR GOOGLE PLAY (ANDROID)
// ===========================================================================

/// Mappage des locales du projet vers les locales spécifiques à Google Play.
/// Basé sur la liste exhaustive du Fastfile, avec les ambiguïtés résolues.
const Map<String, String> _playLocaleMapping = {
  'af': 'af-ZA', 'am': 'am-ET', 'ar': 'ar-EG', 'az': 'az-AZ', 'be': 'be-BY',
  'bg': 'bg-BG', 'bn': 'bn-BD', 'bs': 'bs-BA', 'ca': 'ca-ES', 'cs': 'cs-CZ',
  'da': 'da-DK', 'de': 'de-DE', 'el': 'el-GR', 'en': 'en-US', 'es': 'es-ES',
  'et': 'et','eu': 'eu-ES', 'fa': 'fa-IR', 'fi': 'fi-FI', 'fr': 'fr-FR',
  'gl': 'gl-ES', 'gu': 'gu-IN', 'hi': 'hi-IN', 'hr': 'hr-HR', 'hu': 'hu-HU',
  'hy': 'hy-AM', 'id': 'id-ID', 'is': 'is-IS', 'it': 'it-IT', 'iw': 'iw-IL',
  'ja': 'ja-JP', 'ka': 'ka-GE', 'kk': 'kk-KZ', 'km': 'km-KH', 'kn': 'kn-IN',
  'ko': 'ko-KR', 'ky': 'ky-KG', 'lo': 'lo-LA', 'lt': 'lt-LT', 'lv': 'lv-LV',
  'mk': 'mk-MK', 'ml': 'ml-IN', 'mn': 'mn-MN', 'mr': 'mr-IN', 'ms': 'ms-MY',
  'my': 'my-MM', 'ne': 'ne-NP', 'nl': 'nl-NL', 'no': 'no-NO', 'pa': 'pa-IN',
  'pl': 'pl-PL',
  'pt': 'pt-BR', // Spécifique à Android : Portugais (Brésil)
  'pt-PT': 'pt-PT', 'pt-BR': 'pt-BR',
  'ro': 'ro-RO', 'ru': 'ru-RU', 'si': 'si-LK', 'sk': 'sk-SK', 'sl': 'sl-SI',
  'sq': 'sq-AL', 'sr': 'sr-Latn', 'sv': 'sv-SE', 'sw': 'sw-KE', 'ta': 'ta-IN',
  'te': 'te-IN', 'th': 'th-TH', 'tr': 'tr-TR', 'uk': 'uk', 'ur': 'ur-PK',
  'uz': 'uz-UZ', 'vi': 'vi-VN',
  'zh': 'zh-CN', 'zh-TW': 'zh-TW', 'zh-HK': 'zh-HK',
  'zu': 'zu-ZA'
};

/// Liste des locales officiellement supportées par le Google Play Store.
const Set<String> _playSupportedLocales = {
  'af-ZA', 'am-ET', 'ar-EG', 'az-AZ', 'be-BY', 'bg-BG', 'bn-BD', 'bs-BA',
  'ca-ES', 'cs-CZ', 'da-DK', 'de-DE', 'el-GR', 'en-US', 'en-GB', 'en-AU',
  'en-CA', 'en-IN', 'en-SG', 'en-ZA', 'es-ES', 'es-419', 'et', 'eu-ES',
  'fa-IR', 'fi-FI', 'fr-FR', 'fr-CA', 'gl-ES', 'gu-IN', 'hi-IN', 'hr-HR',
  'hu-HU', 'hy-AM', 'id-ID', 'is-IS', 'it-IT', 'iw-IL', 'ja-JP', 'ka-GE',
  'kk-KZ', 'km-KH', 'kn-IN', 'ko-KR', 'ky-KG', 'lo-LA', 'lt-LT', 'lv-LV',
  'mk-MK', 'ml-IN', 'mn-MN', 'mr-IN', 'ms-MY', 'my-MM', 'ne-NP', 'nl-NL',
  'no-NO', 'pa-IN', 'pl-PL', 'pt-BR', 'pt-PT', 'ro-RO', 'ru-RU', 'si-LK',
  'sk-SK', 'sl-SI', 'sq-AL', 'sr-Latn', 'sv-SE', 'sw-KE', 'ta-IN',
  'te-IN', 'th-TH', 'tr-TR', 'uk', 'ur-PK', 'uz-UZ', 'vi-VN', 'zh-CN',
  'zh-TW', 'zh-HK', 'zu-ZA'
};

/// Convertit une locale du projet en sa version pour le Google Play Store.
String? toPlayLocale(String locale) {
  // Tente un mappage direct
  if (_playLocaleMapping.containsKey(locale)) {
    final playLocale = _playLocaleMapping[locale]!;
    return _playSupportedLocales.contains(playLocale) ? playLocale : null;
  }

  // Gère les cas comme "en_GB" -> "en-GB"
  final match = RegExp(r'^([a-z]{2,3})[_-]([A-Z]{2,3}|[A-Z][a-z]{3})$').firstMatch(locale);
  if (match != null) {
    final lang = match.group(1)!;
    final region = match.group(2)!;
    final playLocale = '$lang-$region';
    if (_playSupportedLocales.contains(playLocale)) {
      return playLocale;
    }
  }

  // Si déjà dans un format supporté
  if (_playSupportedLocales.contains(locale)) {
    return locale;
  }

  return null;
}
