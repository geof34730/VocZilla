import 'dart:convert';
import 'dart:io';


//dart fastlane/generate_metadata.dart

void main() async {


  final projectRoot = Directory.current.path;
  final inputDir = Directory('$projectRoot/lib/l10n');
  final outputDir = Directory('$projectRoot/fastlane/metadata');

  //final inputDir = Directory('lib/l10n');
 // final outputDir = Directory('fastlane/metadata');

  if (!await inputDir.exists()) {
    print('❌ Dossier lib/l10n introuvable.');
    exit(1);
  }
  else{
    print('✅  Dossier lib/l10n trouvé.');
  }
/*
  final files = inputDir
      .listSync()
      .where((f) => f.path.endsWith('.arb') && File(f.path).readAsStringSync().contains('"app_description"'));
*/

  final files = inputDir
      .listSync()
      .where((file) => file.path.endsWith('.arb'))
      .toList();

  print(files);

  for (final file in files) {
    final match = RegExp(r'app_([a-z]{2,3}(?:_[A-Z]{2})?)\.arb').firstMatch(file.path);
    if (match == null) continue;

    final locale = match.group(1)!;
    final content = json.decode(await File(file.path).readAsString());

    final description = content['app_description'] ?? 'description manquante';
    final title = content['app_title'] ?? 'Titre manquant';
    final keywords = content['app_keywords'] ?? 'keyword manquant';
    final shortdescripotion = content['app_short_description'] ?? 'short description manquant';

    final androidLocale = toPlayLocale(locale);
    final iosLocale = toAppleLocale(locale);

    writeMetadata(outputDir.path, '$androidLocale', title, description, keywords, shortdescripotion);
   // writeMetadata(outputDir.path, 'ios/$iosLocale', title, description, keywords, shortdescripotion);

    print('✅ Métadonnées générées pour $locale → $androidLocale / $iosLocale');
  }
}

void writeMetadata(String basePath, String localePath, String title, String desc, String keywords, String shortDesc) {
  final path = '$basePath/$localePath';
  Directory(path).createSync(recursive: true);

  File('$path/title.txt').writeAsStringSync(title.trim());
  File('$path/full_description.txt').writeAsStringSync(desc.trim());
  if (keywords.isNotEmpty) {
    File('$path/keywords.txt').writeAsStringSync(keywords.trim());
  }
  if (shortDesc.isNotEmpty) {
    File('$path/short_description.txt').writeAsStringSync(shortDesc.trim());
  }
}

// Liste officielle des locales supportées par Google Play (2024)
const Map<String, String> mapping = {
  'af': 'af-ZA',
  'am': 'am-ET',
  'ar': 'ar-EG',
  'bg': 'bg-BG',
  'ca': 'ca-ES',
  'cs': 'cs-CZ',
  'da': 'da-DK',
  'de': 'de-DE',
  'el': 'el-GR',
  'en': 'en-US',
  'en-US': 'en-US',
  'en-GB': 'en-GB',
  'es': 'es-ES',
  'es-ES': 'es-ES',
  'es-419': 'es-419',
  'et': 'et',
  'fi': 'fi-FI',
  'fr': 'fr-FR',
  'fr-FR': 'fr-FR',
  'fr-CA': 'fr-CA',
  'he': 'iw-IL', // Google Play utilise "iw" pour hébreu
  'hi': 'hi-IN',
  'hr': 'hr-HR',
  'hu': 'hu-HU',
  'id': 'id-ID',
  'in': 'id-ID', // "in" est l'ancien code pour indonésien
  'is': 'is-IS',
  'it': 'it-IT',
  'ja': 'ja-JP',
  'ko': 'ko-KR',
  'lt': 'lt-LT',
  'lv': 'lv-LV',
  'ms': 'ms-MY',
  'nl': 'nl-NL',
  'no': 'no-NO',
  'pl': 'pl-PL',
  'pt': 'pt-PT',
  'pt-PT': 'pt-PT',
  'pt-BR': 'pt-BR',
  'ro': 'ro-RO',
  'ru': 'ru-RU',
  'sk': 'sk-SK',
  'sl': 'sl-SI',
  'sr': 'sr',
  'sv': 'sv-SE',
  'sw': 'sw',
  'fil': 'fil-PH',
  'th': 'th-TH',
  'tr': 'tr-TR',
  'uk': 'uk',
  'vi': 'vi-VN',
  'zh': 'zh-CN',
  'zh-CN': 'zh-CN',
  'zh-HK': 'zh-HK',
  'zh-TW': 'zh-TW',
  'zu': 'zu',
};

const Set<String> playSupportedLocales = {
  // Ajoute ici tous les codes cibles Google Play (voir la doc officielle)
  'af-ZA','am-ET','ar-EG','bg-BG','ca-ES','cs-CZ','da-DK','de-DE','el-GR','en-US','en-GB','es-ES','es-419','et','fi-FI','fr-FR','fr-CA','iw-IL','hi-IN','hr-HR','hu-HU','id-ID','is-IS','it-IT','ja-JP','ko-KR','lt-LT','lv-LV','ms-MY','nl-NL','no-NO','pl-PL','pt-PT','pt-BR','ro-RO','ru-RU','sk-SK','sl-SI','sr','sv-SE','sw','fil-PH','th-TH','tr-TR','uk','vi-VN','zh-CN','zh-HK','zh-TW','zu'
};

String? toPlayLocale(String locale) {
  // 1. Mapping explicite
  if (mapping.containsKey(locale)) {
    final playLocale = mapping[locale]!;
    return playSupportedLocales.contains(playLocale) ? playLocale : null;
  }

  // 2. xx_XX ou xx-XX → xx-XX
  final match = RegExp(r'^([a-z]{2,3})[_-]([A-Z]{2,3})$').firstMatch(locale);
  if (match != null) {
    final playLocale = '${match.group(1)}-${match.group(2)}';
    return playSupportedLocales.contains(playLocale) ? playLocale : null;
  }

  // 3. xx → mapping ou xx-XX
  final twoLetterLocale = RegExp(r'^[a-z]{2}$');
  if (twoLetterLocale.hasMatch(locale)) {
    final playLocale = '${locale}-${locale.toUpperCase()}';
    return playSupportedLocales.contains(playLocale) ? playLocale : null;
  }

  // 4. Si déjà au bon format et supporté
  if (playSupportedLocales.contains(locale)) {
    return locale;
  }

  // 5. Sinon, non supporté
  return null;
}


String toAppleLocale(String locale) {
  return toPlayLocale(locale) ?? 'en-US'; // Default to en-US if no match found
}
