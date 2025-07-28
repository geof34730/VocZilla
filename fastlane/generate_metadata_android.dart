import 'dart:convert';
import 'dart:io';
import 'locale_mapper.dart';

// 📦 Récupère le dernier build number depuis le fichier JSON
Future<int> getLastBuildNumber() async {
  final file = File('deploy-info.json');
  if (!await file.exists()) {
    throw Exception('deploy-info.json introuvable');
  }
  final content = await file.readAsString();
  final jsonData = json.decode(content);
  return jsonData['lastBuildNumber'];
}

void main() async {
  final projectRoot = Directory.current.path;
  final inputDir = Directory('$projectRoot/lib/l10n');
  final outputDir = Directory('$projectRoot/fastlane/metadata/android');

  // ✅ Vérifie et crée le lien symbolique si nécessaire
  String resolvedPath;
  final expectedLinkTarget = '/Volumes/data/voczilla/metadata/android'; // 🔧 À adapter si besoin

  if (Link(outputDir.path).existsSync()) {
    try {
      resolvedPath = outputDir.resolveSymbolicLinksSync();
    } on FileSystemException {
      final linkTarget = Link(outputDir.path).targetSync();
      print('⚠️ Lien cassé détecté vers : $linkTarget');
      final resolved = Directory(linkTarget);
      if (!resolved.existsSync()) {
        print('📁 Création du dossier cible manquant : $linkTarget');
        resolved.createSync(recursive: true);
      }
      resolvedPath = resolved.path;
    }
  } else {
    print('🔗 Lien symbolique manquant. Création de $outputDir → $expectedLinkTarget');
    Link(outputDir.path).createSync(expectedLinkTarget, recursive: true);
    final resolved = Directory(expectedLinkTarget);
    if (!resolved.existsSync()) {
      print('📁 Création du dossier cible : $expectedLinkTarget');
      resolved.createSync(recursive: true);
    }
    resolvedPath = resolved.path;
  }

  if (!await inputDir.exists()) {
    print('❌ Dossier lib/l10n introuvable.');
    exit(1);
  } else {
    print('✅ Dossier lib/l10n trouvé.');
  }

  final files = inputDir
      .listSync()
      .where((file) => file.path.endsWith('.arb'))
      .toList();

  final buildNumber = await getLastBuildNumber();

  for (final file in files) {
    final match = RegExp(r'app_([a-z]{2,3}(?:_[A-Z]{2})?)\.arb').firstMatch(file.path);
    if (match == null) continue;

    final locale = match.group(1)!;
    final content = json.decode(await File(file.path).readAsString());

    final description = content['app_description'] ?? 'description manquante';
    final title = content['app_title'] ?? 'Titre manquant';
    final keywords = content['app_keywords'] ?? 'keyword manquant';
    final shortDescription = content['app_short_description'] ?? 'short description manquante';
    final releasenote = content['app_release_note'] ?? 'app release note manquante';

    final androidLocale = toPlayLocale(locale);
    if (androidLocale == null) {
      print('⚠️ Locale non supportée ignorée: $locale');
      continue;
    }

    writeMetadata(resolvedPath, androidLocale, title, description, keywords, shortDescription, releasenote, buildNumber);
    print('✅ Métadonnées Android générées pour $locale → $androidLocale');
  }
}

void writeMetadata(String basePath, String localePath, String title, String desc, String keywords, String shortDesc, String releasenote, int buildNumber) {
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
