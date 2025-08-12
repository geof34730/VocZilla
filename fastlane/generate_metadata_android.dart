import 'dart:convert';
import 'dart:io';
import 'locale_mapper.dart';

// 📦 Récupère le dernier build number depuis le fichier JSON
Future<int> getLastBuildNumber() async {
  final file = File('deploy-info.json');
  if (!await file.exists()) {
    throw Exception('Le fichier deploy-info.json est introuvable.');
  }
  final content = await file.readAsString();
  final jsonData = json.decode(content);
  return jsonData['lastBuildNumber'];
}

// 📝 Génère le fichier d'informations pour la révision Google Play
// Les informations sont écrites directement dans cette fonction.
Future<void> generateReviewInformation(String basePath) async {
  // --- VOS INFORMATIONS DE TEST ICI ---
  // ⚠️ ATTENTION : Remplacer les valeurs ci-dessous par vos propres informations de test.
  // Assurez-vous que ce fichier n'est pas versionné dans un dépôt public.
  const login = "voczilla.test2@flutter-now.com";
  const password = "Hefpccy%08%08";
  const notes = """
1. Lancez l'application.
2. Utilisez les identifiants ci-dessus pour vous connecter.
3. Toutes les fonctionnalités sont disponibles sur ce compte de test.
""";
  // ------------------------------------

  // On ne génère pas le fichier si les identifiants n'ont pas été modifiés.
  if (login == "METTRE_VOTRE_LOGIN_ICI" || password == "METTRE_VOTRE_MOT_DE_PASSE_ICI") {
    print('⚠️ Veuillez modifier les identifiants de test (login/password) dans generate_metadata_android.dart.');
    print('   Le fichier review_information.txt n\'a pas été généré.');
    return;
  }

  var reviewContent = 'Informations de connexion pour l\'équipe de révision :\n\n';
  reviewContent += 'Login / Nom d\'utilisateur: $login\n';
  reviewContent += 'Mot de passe: $password\n';

  if (notes.trim().isNotEmpty) {
    reviewContent += '\nInstructions supplémentaires :\n$notes';
  }

  final reviewFilePath = '$basePath/review_information.txt';
  await File(reviewFilePath).writeAsString(reviewContent);
  print('✅ Fichier review_information.txt généré.');
}

void main() async {
  final projectRoot = Directory.current.path;
  final inputDir = Directory('$projectRoot/lib/l10n');
  final outputDir = Directory('$projectRoot/fastlane/metadata/android');

  // 🔧 CHEMIN CIBLE POUR LE LIEN SYMBOLIQUE - À adapter si besoin
  const expectedLinkTarget = '/Volumes/data/voczilla/metadata/android';

  // ✅ Vérifie et gère le lien symbolique vers le dossier de métadonnées
  String resolvedPath;
  if (Link(outputDir.path).existsSync()) {
    try {
      resolvedPath = outputDir.resolveSymbolicLinksSync();
    } on FileSystemException {
      final linkTarget = Link(outputDir.path).targetSync();
      print('⚠️ Lien symbolique cassé détecté vers : $linkTarget');
      final resolved = Directory(linkTarget);
      if (!resolved.existsSync()) {
        print('📁 Création du dossier cible manquant : $linkTarget');
        resolved.createSync(recursive: true);
      }
      resolvedPath = resolved.path;
    }
  } else {
    print('🔗 Lien symbolique manquant. Création de $outputDir → $expectedLinkTarget');
    final targetDir = Directory(expectedLinkTarget);
    if (!targetDir.existsSync()) {
      print('📁 Création du dossier cible manquant : $expectedLinkTarget');
      targetDir.createSync(recursive: true);
    }
    Link(outputDir.path).createSync(expectedLinkTarget, recursive: true);
    resolvedPath = targetDir.path;
  }

  // ✨ Génère les informations pour l'équipe de révision
  await generateReviewInformation(resolvedPath);

  if (!await inputDir.exists()) {
    print('❌ Dossier d\'entrée lib/l10n introuvable.');
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

/// Écrit les fichiers de métadonnées pour une locale donnée.
void writeMetadata(String basePath, String localePath, String title, String desc, String keywords, String shortDesc, String releasenote, int buildNumber) {
  final path = '$basePath/$localePath';
  Directory(path).createSync(recursive: true);

  File('$path/title.txt').writeAsStringSync(title.trim());
  File('$path/full_description.txt').writeAsStringSync(desc.trim());

  // Crée le dossier changelogs et le fichier de note de version
  Directory('$path/changelogs').createSync(recursive: true);
  File('$path/changelogs/$buildNumber.txt').writeAsStringSync(releasenote.trim());

  // N'écrit le fichier que si la valeur n'est pas vide ou le placeholder par défaut
  if (keywords.isNotEmpty && keywords != 'keyword manquant') {
    File('$path/keywords.txt').writeAsStringSync(keywords.trim());
  }

  if (shortDesc.isNotEmpty && shortDesc != 'short description manquante') {
    File('$path/short_description.txt').writeAsStringSync(shortDesc.trim());
  }

  generateReviewInformation(path);

}
