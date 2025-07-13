import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:vobzilla/app_route.dart';
import 'package:vobzilla/main.dart' as app;
import 'package:vobzilla/ui/screens/home_screen.dart';

import '../lib/core/utils/navigatorKey.dart' show navigatorKey;

void main()  {
  const String platform = String.fromEnvironment('PLATFORM', defaultValue: 'android');

  enableFlutterDriverExtension(
    handler: (String? message) async {
      if (message == 'getForFeatureGraphic') {
        const bool forFeatureGraphic = bool.fromEnvironment('FOR_FEATURE_GRAPHIC');
        return forFeatureGraphic.toString();
      }
      if (message == 'getPlatform') return platform;


      return '';
    },
  );
  const String localParameter = String.fromEnvironment('LOCALE', defaultValue: 'en');



  app.main(shootScreenShot: true, localForce: localParameter);
}
