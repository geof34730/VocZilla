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

    final androidLocale = toPlayLocale(locale);
    final iosLocale = toAppleLocale(locale);

    writeMetadata(outputDir.path, 'android/$androidLocale', title, description, keywords);
    writeMetadata(outputDir.path, 'ios/$iosLocale', title, description, keywords);

    print('✅ Métadonnées générées pour $locale → $androidLocale / $iosLocale');
  }
}

void writeMetadata(String basePath, String localePath, String title, String desc, String keywords) {
  final path = '$basePath/$localePath';
  Directory(path).createSync(recursive: true);

  File('$path/title.txt').writeAsStringSync(title.trim());
  File('$path/description.txt').writeAsStringSync(desc.trim());
  if (keywords.isNotEmpty) {
    File('$path/keywords.txt').writeAsStringSync(keywords.trim());
  }
}

String toPlayLocale(String locale) {
  switch (locale) {
    case 'en':
      return 'en-US';
    case 'fr':
      return 'fr-FR';
    case 'pt':
      return 'pt-PT';
    case 'de':
      return 'de-DE';
    case 'es':
      return 'es-ES';
    default:
      return locale;
  }
}

String toAppleLocale(String locale) {
  return toPlayLocale(locale);
}
