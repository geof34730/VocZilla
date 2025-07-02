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

    test('check if the app starts', () async {
     // await driver.screenshot();
      await Future.delayed(Duration(seconds: 15));
      print('Taking screenshot begin...');
      final List<int> pixels = await driver.screenshot();

      // Créez le dossier s'il n'existe pas
      final screenshotsDir = Directory('test_driver/screenshots');
      if (!await screenshotsDir.exists()) {
        await screenshotsDir.create(recursive: true);
      }

      // Nommez le fichier selon vos besoins
      final filePath = path.join(screenshotsDir.path, 'screenshot.png');
      final file = File(filePath);
      await file.writeAsBytes(pixels);

      print('Screenshot saved to $filePath');
      print('Taking screenshot end...');



    });



  });
}
