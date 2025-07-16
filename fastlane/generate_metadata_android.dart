import 'dart:convert';
import 'dart:io';
import 'locale_mapper.dart';


//dart fastlane/generate_metadata.dart
Future<int> getLastBuildNumber() async {
  final file = File('deploy-info.json');
  if (!await file.exists()) {
    throw Exception('deploy-info.json introuvable');
  }
  final content = await file.readAsString();
  final jsonData = json.decode(content);
  int last = jsonData['lastBuildNumber'];
  return last;
}



void main() async {


  final projectRoot = Directory.current.path;
  final inputDir = Directory('$projectRoot/lib/l10n');
  final outputDir = Directory('$projectRoot/fastlane/metadata/android');

  //final inputDir = Directory('lib/l10n');
 // final outputDir = Directory('fastlane/metadata');

  if (!await inputDir.exists()) {
    print('❌ Dossier lib/l10n introuvable.');
    exit(1);
  }
  else{
    print('✅  Dossier lib/l10n trouvé.');
  }

  final files = inputDir
      .listSync()
      .where((file) => file.path.endsWith('.arb'))
      .toList();

  print(files);
  final buildNumber = await getLastBuildNumber();

  for (final file in files) {
    final match = RegExp(r'app_([a-z]{2,3}(?:_[A-Z]{2})?)\.arb').firstMatch(file.path);
    if (match == null) continue;

    final locale = match.group(1)!;
    final content = json.decode(await File(file.path).readAsString());

    final description = content['app_description'] ?? 'description manquante';
    final title = content['app_title'] ?? 'Titre manquant';
    final keywords = content['app_keywords'] ?? 'keyword manquant';
    final shortDescription = content['app_short_description'] ?? 'short description manquant';
    final releasenote = content['app_release_note'] ?? 'app release note manquant';

    final androidLocale = toPlayLocale(locale); // Utilise la bibliothèque partagée
    if (androidLocale == null) {
      print('⚠️ Locale non supportée pour Android ignorée: $locale');
      continue;
    }

    writeMetadata(outputDir.path, androidLocale, title, description, keywords, shortDescription,releasenote,buildNumber);
    print('✅ Métadonnées Android générées pour $locale → $androidLocale');
  }
}

void writeMetadata(String basePath, String localePath, String title, String desc, String keywords, String shortDesc,String releasenote,int buildNumber) {
  final path = '$basePath/$localePath';
  Directory(path).createSync(recursive: true);

  File('$path/title.txt').writeAsStringSync(title.trim());
  File('$path/full_description.txt').writeAsStringSync(desc.trim());
  Directory('$path/changelogs').createSync(recursive: true);
  File('$path/changelogs/$buildNumber.txt').writeAsStringSync(releasenote.trim());
  if (keywords.isNotEmpty) {
    File('$path/keywords.txt').writeAsStringSync(keywords.trim());
  }
  if (shortDesc.isNotEmpty) {
    File('$path/short_description.txt').writeAsStringSync(shortDesc.trim());
  }
}
