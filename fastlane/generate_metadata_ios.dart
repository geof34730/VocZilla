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
  final outputDir = Directory('$projectRoot/fastlane/metadata/ios');

  // ✅ Gère le lien symbolique
  String resolvedPath;
  final expectedLinkTarget = '/Volumes/data/voczilla/metadata/ios';

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

  if (!inputDir.existsSync()) {
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
    final releaseNote = content['app_release_note'] ?? 'app release note manquante';
    final subtitle = content['app_subtitle'] ?? 'app subtitle manquant';

    final iosLocale = toAppleLocale(locale);
    if (iosLocale == null) {
      print('⚠️ Locale non supportée pour iOS ignorée: $locale');
      continue;
    }

    writeMetadata(
      resolvedPath,
      iosLocale,
      title,
      subtitle,
      description,
      keywords,
      shortDescription,
      releaseNote,
      buildNumber,
      "https://flutter-now.com/voczilla-politique-de-confidentialite/",
    );

    print('✅ Métadonnées iOS générées pour $locale → $iosLocale');
  }
}

void writeMetadata(
    String basePath,
    String localePath,
    String title,
    String subtitle,
    String desc,
    String keywords,
    String shortDesc,
    String releaseNote,
    int buildNumber,
    String privacyUrl,
    ) {
  final path = '$basePath/$localePath';
  Directory(path).createSync(recursive: true);
  Directory('$path/app_review_information').createSync(recursive: true);

  final trimmedKeywords = keywords.trim();
  final limitedKeywords = truncateKeywords(trimmedKeywords);
  if (limitedKeywords.length < trimmedKeywords.length) {
    print("⚠️ [$localePath] Keywords tronqués à 100 caractères.");
  }

  final trimmedSubtitle = subtitle.trim();
  final limitedSubtitle = truncateSubtitle(trimmedSubtitle);
  if (limitedSubtitle.length < trimmedSubtitle.length) {
    print("⚠️ [$localePath] Subtitle tronqué à 30 caractères.");
  }

  File('$path/name.txt').writeAsStringSync(title.trim());
  File('$path/description.txt').writeAsStringSync(desc.trim());
  File('$path/keywords.txt').writeAsStringSync(limitedKeywords);
  File('$path/release_notes.txt').writeAsStringSync(releaseNote.trim());
  File('$path/subtitle.txt').writeAsStringSync(limitedSubtitle);
  File('$path/privacy_url.txt').writeAsStringSync(privacyUrl.trim());

  File('$path/app_review_information/first_name.txt').writeAsStringSync("Geoffrey");
  File('$path/app_review_information/last_name.txt').writeAsStringSync("PETAIN");
  File('$path/app_review_information/phone_number.txt').writeAsStringSync("+33 6 59 00 27 62");
  File('$path/app_review_information/email_address.txt').writeAsStringSync("geoffrey.petain@gmail.com");
  File('$path/app_review_information/demo_user.txt').writeAsStringSync("voczilla.test2@flutter-now.com");
  File('$path/app_review_information/demo_password.txt').writeAsStringSync("Hefpccy%08%08");
}

String truncateKeywords(String input) {
  final parts = input.split(',').map((s) => s.trim()).toList();
  List<String> selected = [];
  int totalLength = 0;

  for (final keyword in parts) {
    final length = keyword.length + (selected.isNotEmpty ? 2 : 0);
    if (totalLength + length > 100) break;
    selected.add(keyword);
    totalLength += length;
  }

  return selected.join(', ');
}

String truncateSubtitle(String input) {
  if (input.length <= 30) return input;
  final words = input.split(' ');
  String result = '';

  for (final word in words) {
    if ((result + (result.isEmpty ? '' : ' ') + word).length > 30) break;
    result += (result.isEmpty ? '' : ' ') + word;
  }

  return result;
}
