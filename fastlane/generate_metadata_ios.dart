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
  const expectedLinkTarget = '/Volumes/data/voczilla/metadata/ios';

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
    final baseDescription = content['app_description'] ?? 'description manquante';
    final termsLabel = content['conditions_dutilisation'] ?? 'Terms of Use';
    final privacyLabel = content['politique_de_confidentialite'] ?? 'Privacy Policy';

    // On assemble la description finale avec les liens requis par Apple.
    final finalDescription = '''
$baseDescription

---

$termsLabel (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
$privacyLabel: https://flutter-now.com/voczilla-politique-de-confidentialite/
''';

    final title = content['app_title'] ?? 'Titre manquant';
    final keywords = content['app_keywords'] ?? 'keyword manquant';
    final rawShortPromotion = content['app_promotion_ios'] ?? 'promotion manquante';
    final promotion = truncateShortDescription(rawShortPromotion);

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
      finalDescription,
      keywords,
      promotion,
      releaseNote,
      buildNumber,
      "https://flutter-now.com/voczilla-politique-de-confidentialite/",
      // ✅ Marketing URL = domaine utilisé pour app-ads.txt
      "https://voczilla.com",
    );

    print('✅ Métadonnées iOS générées pour $locale → $iosLocale');
  }
}

// -------- Utils --------

String truncateShortDescription(String input) {
  const maxLength = 140;
  if (input.length <= maxLength) return input;
  // On coupe à (maxLength - 3) pour laisser la place à "..."
  return input.substring(0, maxLength - 3).trimRight() + '...';
}

String truncateKeywords(String input) {
  // ✅ Sépare par virgule standard (,) ou arabe (،)
  final parts = input
      .split(RegExp(r'[,،]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  List<String> selected = [];
  int totalLength = 0;

  for (final keyword in parts) {
    final lengthWithSeparator = keyword.length + (selected.isNotEmpty ? 2 : 0);
    if (totalLength + lengthWithSeparator > 100) break;
    selected.add(keyword);
    totalLength += lengthWithSeparator;
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

// -------- Ecriture des métadonnées --------

void writeMetadata(
    String basePath,
    String localePath,
    String title,
    String subtitle,
    String desc,
    String keywords,
    String promotion,
    String releaseNote,
    int buildNumber,
    String privacyUrl,
    String marketingUrl,
    ) {
  final path = '$basePath/$localePath';
  Directory(path).createSync(recursive: true);
  Directory('$basePath/review_information').createSync(recursive: true);

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

  // 👤 Infos de contact pour la review (facultatif mais pratique)
  File('$basePath/review_information/first_name.txt').writeAsStringSync("Geoffrey");
  File('$basePath/review_information/last_name.txt').writeAsStringSync("PETAIN");
  File('$basePath/review_information/phone_number.txt').writeAsStringSync("+33 6 59 00 27 62");
  File('$basePath/review_information/email_address.txt').writeAsStringSync("geoffrey.petain@gmail.com");
  File('$basePath/review_information/demo_user.txt').writeAsStringSync("");
  File('$basePath/review_information/demo_password.txt').writeAsStringSync("");

  // 📝 Champs localisés
  File('$path/name.txt').writeAsStringSync(title.trim());
  File('$path/description.txt').writeAsStringSync(desc.trim());
  File('$path/keywords.txt').writeAsStringSync(limitedKeywords);
  File('$path/release_notes.txt').writeAsStringSync(releaseNote.trim());
  File('$path/subtitle.txt').writeAsStringSync(limitedSubtitle);
  File('$path/privacy_url.txt').writeAsStringSync(privacyUrl.trim());
  File('$path/promotional_text.txt').writeAsStringSync(promotion.trim());
  File('$path/support_url.txt').writeAsStringSync(
    "https://docs.google.com/forms/d/e/1FAIpQLSfkcK4ry-8CoUWEvyDSC9e79HK_8d6lyPbWQtP9_au2kc2J3g/viewform",
  );

  // 🌐 Marketing URL → « Site web du développeur » (utilisé pour app-ads.txt)
  File('$path/marketing_url.txt').writeAsStringSync(marketingUrl.trim());
}
