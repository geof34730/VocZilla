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

/// ===========================================================================
// LOGIQUE POUR GOOGLE PLAY (ANDROID) - CORRIGÉ
// ===========================================================================

/// Mappage des locales du projet vers les locales spécifiques à Google Play.
/// CORRIGÉ : Cette table est maintenant basée sur la liste officielle de votre
/// fiche Play Store. Elle résout les ambiguïtés (ex: 'fr' -> 'fr-FR') et
/// mappe les codes simples vers eux-mêmes si c'est le format attendu.
const Map<String, String> _playLocaleMapping = {
  // Mappages directs (le code simple est le format attendu)
  'af': 'af',  'am': 'am', 'bg': 'bg', 'ca': 'ca','lv': 'lv',
  'hr': 'hr',  'et': 'et',  'el': 'el-GR',
  'lt': 'lt', 'ms': 'ms',  'ro': 'ro',
   'sr': 'sr', 'sk': 'sk', 'sl': 'sl',  'sw': 'sw',
  'fil': 'fil', 'cs': 'cs-CZ', 'th': 'th',  'uk': 'uk', 'vi': 'vi',
  'zu': 'zu','gu':'gu','kk':'kk','pa':'pa','sq':'sq','ur':'ur',

  // Gestion de l'Indonésien (id/in)
  'id': 'id',
  'in': 'id', // 'in' est un ancien code pour 'id'

  // Mappages pour résoudre les ambiguïtés ou suivre des règles spécifiques
  'fr': 'fr-FR', // Instruction explicite : fr -> fr-FR
  'en': 'en-US', // Défaut pour 'en'
  'es': 'es-ES', // Défaut pour 'es'
  'pt': 'pt-BR', // Défaut pour 'pt'
  'zh': 'zh-CN', // Défaut pour 'zh'
  'sv': 'sv-SE',
  'ta' : 'ta-IN',
  'te': 'te-IN',// Défaut pour 'ta-IN"
  'tr': 'tr-TR',
  'de': 'de-DE',
  'fi': 'fi-FI',
  'hi': 'hi-IN',
  'hu': 'hu-HU',
  'is': 'is-IS',
  'it': 'it-IT',
  'ja': 'ja-JP',
  'ko': 'ko-KR',
  'nl': 'nl-NL',
  'no' :'no-NO',
  'pl': 'pl-PL',
  'ru': 'ru-RU',
  'da': 'da-DK',
  // Mappages régionaux qui sont déjà corrects et supportés (pour la robustesse)
  'en-US': 'en-US', 'en-GB': 'en-GB', 'zh-HK': 'zh-HK', 'zh-CN': 'zh-CN',
  'zh-TW': 'zh-TW', 'es-419': 'es-419', 'es-ES': 'es-ES', 'fr-CA': 'fr-CA',
  'fr-FR': 'fr-FR', 'pt-BR': 'pt-BR', 'pt-PT': 'pt-PT',
};

/// CORRIGÉ : Liste des locales officiellement supportées par VOTRE Google Play Store.
const Set<String> _playSupportedLocales = {
  'af', 'de', 'am', 'en-US', 'en-GB', 'bg', 'ca', 'zh-HK', 'zh-CN', 'zh-TW',
  'ko', 'hr', 'da', 'es-419', 'es-ES', 'et', 'fi', 'fr-CA', 'fr-FR', 'el',
   'hi', 'hu', 'id', 'in', 'is', 'it', 'ja', 'lv', 'lt', 'ms', 'nl',
  'no', 'pl', 'pt-BR', 'pt-PT', 'ro', 'ru', 'sr', 'sk', 'sl', 'sv', 'sw',
  'fil', 'cs', 'th', 'tr', 'uk', 'vi', 'zu','gu','kk','pa','sq','ta','te','ur'
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
