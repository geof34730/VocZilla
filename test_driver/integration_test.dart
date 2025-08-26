import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('App Integration Tests', () {
    late FlutterDriver driver;
    late String platform;
    late String destFolder;
    late bool forFeatureGraphic;

    // ------- Utils -------
    Future<void> takeScreenshot(FlutterDriver driver, String name) async {
      final pixels = await driver.screenshot();
      final screenshotsDir = Directory('test_driver/screenshots');
      if (!await screenshotsDir.exists()) {
        await screenshotsDir.create(recursive: true);
      }
      final filePath = path.join(screenshotsDir.path, '$name.png');
      final file = File(filePath);
      await file.writeAsBytes(pixels);
      print('📸 Screenshot saved to $filePath');
    }

    Future<void> scrollUntilVisibleAndTap(
        FlutterDriver driver,
        SerializableFinder scrollableFinder,
        SerializableFinder itemFinder, {
          double dx = 0,
          double dy = -300,
          int maxScrolls = 10,
          Duration duration = const Duration(milliseconds: 500),
        }) async {
      bool found = false;
      int scrollCount = 0;
      while (!found && scrollCount < maxScrolls) {
        try {
          await driver.waitFor(itemFinder, timeout: const Duration(seconds: 2));
          await driver.tap(itemFinder);
          found = true;
          print("✅ Élément trouvé et tapé après $scrollCount scroll(s).");
        } catch (_) {
          print("🔁 Scroll... ($scrollCount/$maxScrolls)");
          await driver.scroll(scrollableFinder, dx, dy, duration);
          scrollCount++;
        }
      }
      if (!found) {
        throw Exception("❌ Élément introuvable après $maxScrolls scrolls.");
      }
    }

    int _iosIndex = 0;
    String getNameFile(String value) {
      // Log de contrôle
      print("*********************$value   -   $platform - $platform");
      if (platform == 'ios') {
        _iosIndex++;
        return "${destFolder}_0$_iosIndex";
      } else {
        return value;
      }
    }

    Future<void> tapBackButton(FlutterDriver driver) async {
      final appBar = find.byValueKey("appBarKey");
      await driver.waitFor(appBar);

      final back = find.descendant(
        of: appBar,
        matching: find.byType('BackButton'),
        firstMatchOnly: true,
      );
      await driver.tap(back);
    }

    /// [NOUVEAU] Helper pour créer une liste personnalisée avec une couleur spécifique.
    /// Cette fonction suppose que le driver est sur l'écran `perso_list_step1`.
    Future<void> createListWithColor(
        FlutterDriver driver,
        String title,
        int colorSwatchIndex,
        bool shootStep1
        ) async {
      print("  - Saisie du titre : $title");
      await driver.tap(find.byValueKey('title_perso_field'));
      await driver.enterText(title);



      print("  - Sélection de la pastille de couleur (index: $colorSwatchIndex)");
      // On utilise la clé unique que nous avons ajoutée. L'index commence à 0 dans l'appel,
      // mais nos clés commencent à 'color_1', donc on ajoute 1.
      final colorKey = 'color_${colorSwatchIndex + 1}';
      final colorFinder = find.byValueKey(colorKey);
      await driver.waitFor(colorFinder);
      await driver.tap(colorFinder);
      if (shootStep1) {
        await takeScreenshot(driver, getNameFile('personallist_step1'));
      }
      print("  - Clic sur 'Suivant' pour passer à l'étape 2");
      await driver.tap(find.byValueKey('button_valide_step_perso'));

    }


    // ------- Lifecycle -------
    setUpAll(() async {
      driver = await FlutterDriver.connect(timeout: const Duration(minutes: 2));

      // 1) Lire les variables d'environnement côté test (injectées par la commande shell)
      final env = Platform.environment;
      final envPlatform = env['PLATFORM']; // "ios" | "android"
      final envLocale = env['LOCALE']; // ex: "cs"
      final envDestFolder = env['DESTFOLDER']; // ex: "iphone6_7_inch"
      final envFeatureStr = env['FOR_FEATURE_GRAPHIC']; // "true" | "false" | "1" | "0"
      final envFeature = (envFeatureStr == 'true' || envFeatureStr == '1');

      // 2) Envoyer la config runtime à l'app (Option 3) — pas de rebuild nécessaire
      final payload = <String, dynamic>{
        'cmd': 'setConfig',
        if (envPlatform != null) 'platform': envPlatform,
        if (envLocale != null) 'locale': envLocale,
        if (envDestFolder != null) 'destFolder': envDestFolder,
        // on n’envoie 'feature' que si présent (sinon on laisse la valeur par défaut app)
        if (envFeatureStr != null) 'feature': envFeature,
      };

      if (payload.length > 1) { // il y a au moins cmd + 1 champ
        final res = await driver.requestData(json.encode(payload));
        print('🚀 setConfig response: $res');
      } else {
        print('ℹ️ Aucune variable d’environnement fournie — on utilisera les valeurs par défaut de l’app.');
      }

      // 3) Récupérer/valider les valeurs finales (fallback si pas d’ENV fourni)
      platform = envPlatform ?? await driver.requestData('getPlatform');
      print('📦 PLATFORM = $platform');

      destFolder = envDestFolder ?? await driver.requestData('getDestFolder');
      print('📦 DESTFOLDER = $destFolder');

      if (envFeatureStr != null) {
        forFeatureGraphic = envFeature;
      } else {
        final forFeatureGraphicStr = await driver.requestData('getForFeatureGraphic');
        forFeatureGraphic = forFeatureGraphicStr == 'true';
      }
      print('📦 FOR_FEATURE_GRAPHIC: $forFeatureGraphic');
    });

    tearDownAll(() async {
      await driver.close();
    });

    // ------- Test principal -------
    test(
      'check if the app starts',
          () async {
        if (forFeatureGraphic) {
          await takeScreenshot(driver, 'featureGraphic');
          return;
        }

        await takeScreenshot(driver, getNameFile('home'));

        await driver.tap(find.byValueKey('link_home_login'));

        await driver.waitFor(find.byValueKey('home_logged'));
        await takeScreenshot(driver, getNameFile('homeperso'));

        // --- [MODIFIÉ] Création de 3 listes avec des couleurs différentes ---

        // Liste 1
        print('➡️ Création de "My personal list 1" avec la première couleur...');
        await driver.tap(find.byValueKey('buttonAddList'));
        await driver.waitFor(find.byValueKey('perso_list_step1'));
        await createListWithColor(driver, 'My personal list 1', 8, true); // 1ère couleur (index 0)
        await driver.waitFor(find.byValueKey('perso_list_step2'));
        print("  - Ajout de quelques mots de vocabulaire");
        await driver.tap(find.byValueKey('button_add_voc_1'));
        await driver.tap(find.byValueKey('button_add_voc_2'));
        await driver.tap(find.byValueKey('button_add_voc_4'));
        await takeScreenshot(driver, getNameFile('personallist_step2'));
        print("  - Retour à l'écran d'accueil des listes");
        await tapBackButton(driver);
        await driver.waitFor(find.byValueKey('home_logged'));



        // Liste 2
        print('➡️ Création de "My personal list 2" avec une couleur différente...');
        await driver.tap(find.byValueKey('button_create_list'));
        await driver.waitFor(find.byValueKey('perso_list_step1'));
        await createListWithColor(driver, 'My personal list 2', 6,false);
        print("  - Ajout de quelques mots de vocabulaire");
        await driver.tap(find.byValueKey('button_add_voc_1'));
        await driver.tap(find.byValueKey('button_add_voc_2'));
        await driver.tap(find.byValueKey('button_add_voc_4'));
        print("  - Retour à l'écran d'accueil des listes");
        await tapBackButton(driver);
        await driver.waitFor(find.byValueKey('home_logged'));

        // Liste 3
        print('➡️ Création de "My personal list 3" avec une autre couleur...');
        await driver.tap(find.byValueKey('button_create_list'));
        await driver.waitFor(find.byValueKey('perso_list_step1'));
        await createListWithColor(driver, 'My personal list 3', 3,false); // 11ème couleur (index 10)
        print("  - Ajout de quelques mots de vocabulaire");
        await driver.tap(find.byValueKey('button_add_voc_1'));
        await driver.tap(find.byValueKey('button_add_voc_2'));
        await driver.tap(find.byValueKey('button_add_voc_4'));
        print("  - Retour à l'écran d'accueil des listes");
        await tapBackButton(driver);

        await driver.waitFor(find.byValueKey('home_logged'));
        await takeScreenshot(driver, getNameFile('homepersolist'));

        // --- [MODIFIÉ] Suppression des 3 listes créées ---
        print('➡️ Suppression des 3 listes créées...');
        final deleteButtonFinder = find.byValueKey('buttonDeletePerso1');

        for (int i = 1; i <= 3; i++) {
          print('  - Suppression de la liste $i/3...');
          // Cette logique suppose que le bouton de suppression de la première liste
          // visible a toujours la clé 'buttonDeletePerso1'.
          await driver.waitFor(deleteButtonFinder);
          await driver.tap(deleteButtonFinder);
          // Délai pour laisser l'UI se mettre à jour.
          await Future.delayed(const Duration(seconds: 2));
        }

        // --- Suite du test original ---

        // Learn
        await driver.tap(find.byValueKey('buttonLearntop20'));
        await driver.waitFor(find.byValueKey('screenLearn'));
        await takeScreenshot(driver, getNameFile('screenlearn'));
        await tapBackButton(driver);

        // Dictation
        await driver.tap(find.byValueKey('buttonVoiceDictationtop20'));
        await driver.waitFor(find.byValueKey('screenVoicedictation'));
        await takeScreenshot(driver, getNameFile('voicedictation'));
        await tapBackButton(driver);

        // Quizz
        await driver.tap(find.byValueKey('buttonQuizztop20'));
        await driver.waitFor(find.byValueKey('screenQuizz'));
        await takeScreenshot(driver, getNameFile('quizz'));
        await tapBackButton(driver);


        if (platform == 'ios') {
          // pronunciation
          await driver.tap(find.byValueKey('buttonPrononciationtop20'));
          await driver.waitFor(find.byValueKey('screenPrononciation'));
          await takeScreenshot(driver, getNameFile('Prononciation'));
          await tapBackButton(driver);

          //List
          await driver.tap(find.byValueKey('buttonListtop20'));
          await driver.waitFor(find.byValueKey('screenList'));
          await takeScreenshot(driver, getNameFile('Liste'));
          await tapBackButton(driver);

        }

        print('find open_drawer_voczilla');
        await driver.tap(find.byValueKey('open_drawer_voczilla'));
        print('ok open_drawer_voczilla');

        print('find link_logout');
        await driver.tap(find.byValueKey('link_logout'));
        print('ok link_logout');

        print('✅ Fin des screenshots');
      },
      timeout: const Timeout(Duration(minutes: 5)), // Augmentation du timeout pour les tests plus longs
    );
  });
}
