import 'dart:convert';
import 'dart:io';
import 'locale_mapper.dart';

// dart fastlane/generate_metadata_ios.dart
Future<int> getLastBuildNumber() async {
  final file = File('deploy-info.json');
  if (!await file.exists()) {
    throw Exception('deploy-info.json introuvable');
  }
  final content = await file.readAsString();
  final jsonData = json.decode(content);
  int last = jsonData['lastBuildNumber'];
  return last+1;
}

void main() async {
  final projectRoot = Directory.current.path;
  final inputDir = Directory('$projectRoot/lib/l10n');
  final outputDir = Directory('$projectRoot/fastlane/metadata/ios');

  if (!await inputDir.exists()) {
    print('❌ Dossier lib/l10n introuvable.');
    exit(1);
  } else {
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
    final releaseNote = content['app_release_note'] ?? 'app release note manquant';
    final String subtitle=content['app_subtitle'] ?? 'app subtitle manquant';
    final iosLocale = toAppleLocale(locale); // Utilise la bibliothèque partagée

    writeMetadata(
      outputDir.path,
      iosLocale!,
      title,
      subtitle,
      description,
      keywords,
      shortDescription,
      releaseNote,
      buildNumber,
      "https://flutter-now.com/voczilla-politique-de-confidentialite/"
    );

    print('✅ Métadonnées générées pour $locale → $iosLocale');
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
  Directory("$path/app_review_information").createSync(recursive: true);

  // Keywords
  final trimmedKeywords = keywords.trim();
  final limitedKeywords = truncateKeywords(trimmedKeywords);
  if (limitedKeywords.length < trimmedKeywords.length) {
    print("⚠️ [$localePath] Keywords truncated to 100 characters.");
  }

  // Subtitle
  final trimmedSubtitle = subtitle.trim();
  final limitedSubtitle = truncateSubtitle(trimmedSubtitle);
  if (limitedSubtitle.length < trimmedSubtitle.length) {
    print("⚠️ [$localePath] Subtitle truncated to 30 characters.");
  }

  // Fichiers attendus par Fastlane/deliver pour iOS
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
  File('$path/app_review_information/demo_user.txt').writeAsStringSync("geoffrey.petain@gmail.com");
  File('$path/app_review_information/demo_password.txt').writeAsStringSync("sdfsdfs@ddd-df");
}


/// Nettoie les mots-clés de caractères invisibles ou problématiques
String cleanKeywords(String input) {
  return input
      .replaceAll(RegExp(r'\s+'), ' ') // espaces multiples, tab, \n, etc. -> 1 espace
      .replaceAll(String.fromCharCode(160), ' ') // remplace U+00A0 (espace insécable)
      .trim();
}

/// Limite à 100 caractères max sans couper les mots (séparés par virgule)
String truncateKeywords(String input) {
  final parts = input.split(',').map((s) => s.trim()).toList();
  List<String> selected = [];
  int totalLength = 0;

  for (final keyword in parts) {
    int keywordLength = keyword.length + (selected.isNotEmpty ? 2 : 0); // +2 pour ", "
    if (totalLength + keywordLength > 100) break;
    selected.add(keyword);
    totalLength += keywordLength;
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
