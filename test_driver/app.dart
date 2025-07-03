import 'package:flutter_driver/driver_extension.dart';
import 'package:vobzilla/main.dart' as app;
void main() async {
  enableFlutterDriverExtension();
  const String localParameter = String.fromEnvironment('LOCALE', defaultValue: 'en');



  app.main(shootScreenShot: true, localForce:localParameter );
}
