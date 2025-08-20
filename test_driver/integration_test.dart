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

        print('find buttonAddList');
        await driver.tap(find.byValueKey('buttonAddList'));
        print('ok buttonAddList');
        await driver.waitFor(find.byValueKey('perso_list_step1'));
        await driver.tap(find.byValueKey('title_perso_field'));
        await driver.enterText('My personal list 1');
        await takeScreenshot(driver, getNameFile('personallist1'));

        await driver.tap(find.byValueKey('button_valide_step_perso'));
        await driver.waitFor(find.byValueKey('perso_list_step2'));
        await takeScreenshot(driver, getNameFile('personallist2'));

        await driver.tap(find.byValueKey('button_add_voc_1'));
        await driver.tap(find.byValueKey('button_add_voc_2'));
        await driver.tap(find.byValueKey('button_add_voc_4'));

        await tapBackButton(driver);


        print('find button_create_list');
        await driver.tap(find.byValueKey('button_create_list'));
        print('ok button_create_list');
        await driver.waitFor(find.byValueKey('perso_list_step1'));
        await driver.tap(find.byValueKey('title_perso_field'));
        await driver.enterText('My personal list 2');


        await driver.tap(find.byValueKey('button_valide_step_perso'));
        await driver.waitFor(find.byValueKey('perso_list_step2'));


        await driver.tap(find.byValueKey('button_add_voc_1'));
        await driver.tap(find.byValueKey('button_add_voc_2'));
        await driver.tap(find.byValueKey('button_add_voc_4'));

        await tapBackButton(driver);


        print('find button_create_list');
        await driver.tap(find.byValueKey('button_create_list'));
        print('ok button_create_list');
        await driver.waitFor(find.byValueKey('perso_list_step1'));
        await driver.tap(find.byValueKey('title_perso_field'));
        await driver.enterText('My personal list 3');


        await driver.tap(find.byValueKey('button_valide_step_perso'));
        await driver.waitFor(find.byValueKey('perso_list_step2'));


        await driver.tap(find.byValueKey('button_add_voc_1'));
        await driver.tap(find.byValueKey('button_add_voc_2'));
        await driver.tap(find.byValueKey('button_add_voc_4'));

        await tapBackButton(driver);

        print('find button_create_list');
        await driver.tap(find.byValueKey('button_create_list'));
        print('ok button_create_list');
        await driver.waitFor(find.byValueKey('perso_list_step1'));
        await driver.tap(find.byValueKey('title_perso_field'));
        await driver.enterText('My personal list 4');


        await driver.tap(find.byValueKey('button_valide_step_perso'));
        await driver.waitFor(find.byValueKey('perso_list_step2'));


        await driver.tap(find.byValueKey('button_add_voc_1'));
        await driver.tap(find.byValueKey('button_add_voc_2'));
        await driver.tap(find.byValueKey('button_add_voc_4'));

        await tapBackButton(driver);


        await driver.waitFor(find.byValueKey('home_logged'));
        await takeScreenshot(driver, getNameFile('homepersolist'));




        final deleteButtonFinder1 = find.byValueKey('buttonDeletePerso1');
        await driver.waitFor(deleteButtonFinder1);
        await driver.tap(deleteButtonFinder1);
        await Future.delayed(Duration(seconds: 2));
        final deleteButtonFinder2 = find.byValueKey('buttonDeletePerso1');
        await driver.waitFor(deleteButtonFinder2);
        await driver.tap(deleteButtonFinder2);
        await Future.delayed(Duration(seconds: 2));
        final deleteButtonFinder3 = find.byValueKey('buttonDeletePerso1');
        await driver.waitFor(deleteButtonFinder3);
        await driver.tap(deleteButtonFinder3);
        await Future.delayed(Duration(seconds: 2));
        final deleteButtonFinder4 = find.byValueKey('buttonDeletePerso1');
        await driver.waitFor(deleteButtonFinder4);
        await driver.tap(deleteButtonFinder4);







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


/*
        print('find open_drawer_voczilla');
        await driver.tap(find.byValueKey('open_drawer_voczilla'));
        print('ok open_drawer_voczilla');

        print('find link_subscription');
        await driver.tap(find.byValueKey('link_subscription'));
        print('ok link_subscription');

        await driver.waitFor(find.byValueKey('screenSubscription'));
        await takeScreenshot(driver, getNameFile('scrSeenSubscription'));
*/

        print('find open_drawer_voczilla');
        await driver.tap(find.byValueKey('open_drawer_voczilla'));
        print('ok open_drawer_voczilla');

        print('find link_logout');
        await driver.tap(find.byValueKey('link_logout'));
        print('ok link_logout');




        print('✅ Fin des screenshots');
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });
}
