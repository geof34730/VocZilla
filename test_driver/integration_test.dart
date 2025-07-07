import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  group('App Integration Tests', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
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
      print('Screenshot saved to $filePath');
    }

    /// Scroll jusqu'à ce que [itemFinder] soit visible, puis tap dessus.
    /// [scrollableFinder] doit cibler le widget scrollable parent (ex: ListView, SingleChildScrollView).
    Future<void> scrollUntilVisibleAndTap(
        FlutterDriver driver,
        SerializableFinder scrollableFinder,
        SerializableFinder itemFinder, {
          double dx = 0,
          double dy = -10,
          int maxScrolls = 10,
          Duration duration = const Duration(milliseconds: 500),
        }) async {
      bool isVisible = false;
      int scrollCount = 0;
      while (!isVisible && scrollCount < maxScrolls) {
        try {
          await driver.tap(itemFinder);
          isVisible = true;
        } catch (e) {
          await driver.scroll(scrollableFinder, dx, dy, duration);
          scrollCount++;
        }
      }
      if (!isVisible) {
        throw Exception('Item not found after scrolling');
      }
    }

    test('check if the app starts', () async {
      await Future.delayed(Duration(seconds: 5));
      // Récupère la valeur de FOR_FEATURE_GRAPHIC depuis l'app
      final forFeatureGraphicStr = await driver.requestData('getForFeatureGraphic');
      print("forFeatureGraphicStr: $forFeatureGraphicStr");
      final forFeatureGraphic = forFeatureGraphicStr == 'true';
      print('FOR_FEATURE_GRAPHIC from app: $forFeatureGraphic');

      if (forFeatureGraphic) {
        print('Taking screenshot featureGraphic...');
        await takeScreenshot(driver, 'featureGraphic');
      } else {
        print('Taking screenshot Home...');
        await takeScreenshot(driver, 'home');

        // Attendre que le bouton de login soit présent dans l'arbre

        await driver.waitFor(find.byValueKey('link_home_login'));
        await driver.waitFor(find.byValueKey('scrollBackgroundBlueLinear'));
        print('clique link_home_login..');

        // SCROLL jusqu'à ce que le bouton soit visible, puis tap
        final scrollableFinder = find.byValueKey('scrollBackgroundBlueLinear');
        final loginButtonFinder = find.byValueKey('link_home_login');
        await scrollUntilVisibleAndTap(
            driver, scrollableFinder, loginButtonFinder);

        await driver.waitFor(find.byValueKey('login_screen'));

        print('Taking screenshot login_screen...');
        await takeScreenshot(driver, 'login_screen');

        await driver.waitFor(find.byValueKey('login_field'));
        await driver.tap(find.byValueKey('login_field'));
        await driver.enterText('geoffrey.petain@gmail.com');

        await driver.waitFor(find.byValueKey('password_field'));
        await driver.tap(find.byValueKey('password_field'));
        await driver.enterText('sdfsdfs@ddd-df');

        await driver.waitFor(find.byValueKey('validate_login_button'));
        await driver.tap(find.byValueKey('validate_login_button'));

        await driver.waitFor(find.byValueKey('home_logged'));

        await takeScreenshot(driver, 'home_logged');
        print('Taking screenshot end...');
      }
    });
  });
}
