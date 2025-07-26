import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'package:path/path.dart' as path;




void main() {
  group('App Integration Tests', () {
    late FlutterDriver driver;
    late String platform;
    late String destFolder;


    setUpAll(() async {
      driver = await FlutterDriver.connect();
      platform = await driver.requestData('getPlatform');
      print('📦 PLATFORM = $platform');
      destFolder = await driver.requestData('getDestFolder');
      print('📦 DESTFOLDER = $destFolder');

    });

    tearDownAll(() async {
      await driver.close();
    });

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
          await driver.waitFor(itemFinder, timeout: Duration(seconds: 2));
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


    int i=0;
    String getNameFile(String value) {
      print("*********************$value   -   $platform - $platform");
      if (platform == 'ios') {
        i++;
        return "${destFolder}_0${i}";
       } else {
        return "$value";
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

    test(
      'check if the app starts',
          () async {
        await Future.delayed(Duration(seconds: 5));

        final forFeatureGraphicStr = await driver.requestData('getForFeatureGraphic');
        final forFeatureGraphic = forFeatureGraphicStr == 'true';
        print('📦 FOR_FEATURE_GRAPHIC: $forFeatureGraphic');

        if (forFeatureGraphic) {
          await takeScreenshot(driver, 'featureGraphic');
          return;
        }

        await takeScreenshot(driver, getNameFile('home'));


        await driver.tap(find.byValueKey('link_home_login'));




        await driver.waitFor(find.byValueKey('login_screen'));

        await driver.waitFor(find.byValueKey('login_screen'));
        await takeScreenshot(driver, getNameFile('login_screen'));

        await driver.tap(find.byValueKey('login_field'));
        await driver.enterText('voczilla.test2@flutter-now.com');
        await driver.tap(find.byValueKey('password_field'));
        await driver.enterText('Hefpccy%08%08');

        await driver.waitFor(find.byValueKey('validate_login_button'));
        await driver.tap(find.byValueKey('validate_login_button'));

        await driver.waitFor(find.byValueKey('home_logged'));
        await takeScreenshot(driver, getNameFile('homeperso'));


        await driver.tap(find.byValueKey('button_create_list'));

        await driver.waitFor(find.byValueKey('perso_list_step1'));
        await driver.tap(find.byValueKey('title_perso_field'));
        await driver.enterText('My personal list');
        await takeScreenshot(driver, getNameFile('personallist1'));

        await driver.tap(find.byValueKey('button_valide_step_perso'));
        await driver.waitFor(find.byValueKey('perso_list_step2'));
        await takeScreenshot(driver, getNameFile('personallist2'));

        await driver.tap(find.byValueKey('button_add_voc_1'));
        await driver.tap(find.byValueKey('button_add_voc_2'));
        await driver.tap(find.byValueKey('button_add_voc_4'));


        await tapBackButton(driver);

        final deleteButtonFinder = find.byValueKey('buttonDeletePerso1');
            await driver.waitFor(deleteButtonFinder);
            await driver.tap(deleteButtonFinder);



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

        print('✅ Fin des screenshots');
      },
      timeout: Timeout(Duration(minutes: 10)),
    );
  });
}
