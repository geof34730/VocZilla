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
      if (driver != null) {
        await driver.close();
      }
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


    test('check if the app starts', () async {
     // await driver.screenshot();
      await Future.delayed(Duration(seconds: 3));
      print('Taking screenshot Home...');
      await takeScreenshot(driver, 'home');

      // Attendre que le bouton de login soit visible
      await driver.waitFor(find.byValueKey('link_home_login'));

      print('clique link_home_login..');
      await driver.tap(find.byValueKey('link_home_login'));

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



    });



  });

}
