import 'package:flutter_driver/driver_extension.dart';
import 'package:vobzilla/main.dart' as app;
void main()  {
  enableFlutterDriverExtension(
    handler: (String? message) async {
      if (message == 'getForFeatureGraphic') {
        const bool forFeatureGraphic = bool.fromEnvironment('FOR_FEATURE_GRAPHIC');
        return forFeatureGraphic.toString();
      }
      return '';
    },
  );


  const String localParameter = String.fromEnvironment('LOCALE', defaultValue: 'en');

  app.main(shootScreenShot: true, localForce:localParameter );
}
