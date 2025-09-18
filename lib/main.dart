import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/utils/logger.dart';
import 'data/repository/vocabulaire_user_repository.dart';
import 'data/services/firebase_messaging_service.dart';
import 'data/services/notification_service.dart';
import 'firebase_initialiser.dart';
import 'package:voczilla/app.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'global.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

FirebaseMessaging messaging = FirebaseMessaging.instance;
StreamSubscription<Uri>? _linkSubscription;
final _appLinks = AppLinks();

void main({
  bool shootScreenShot = false,
  String? localForce=null,
  bool forFeatureGraphicParam=false
}) async {

  if(localForce!=null){
    testScreenShot=true;
    debugMode=false;
  }

  WidgetsFlutterBinding.ensureInitialized();
  forFeatureGraphic=forFeatureGraphicParam;
  if(!testScreenShot) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await FirebaseInitializer.initialize();
/*
  // ACTIVER APP CHECK ICI AVEC GESTION D'ERREUR
  try {
    Logger.Red.log("--- Début de l'activation de Firebase App Check ---");
    await FirebaseAppCheck.instance.activate(
      // Pour le web, si vous l'utilisez
      // webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'), // Remplacez par votre clé reCAPTCHA v3
      // Pour Android
      androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      // Pour iOS
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    );
    Logger.Red.log("--- Firebase App Check activé avec succès ---");
  } catch (e) {
    Logger.Red.log("--- ERREUR FATALE LORS DE L'ACTIVATION D'APP CHECK ---");
    Logger.Red.log(e);
    Logger.Red.log("----------------------------------------------------");
  }
*/

  if (!testScreenShot) {
    final notificationService = NotificationService();
    await notificationService.initialize();
    if(!Platform.isMacOS) {
      final messagingService = FirebaseMessagingService();
      await messagingService.configure();
    }
  }

  await _initAppLinks();

  final vocabulaireUserRepository = VocabulaireUserRepository();
  await vocabulaireUserRepository.updateListTheme();


  runApp(MyApp(localForce:localForce));
}

Future<void> _initAppLinks() async {
  // Listen to incoming links
  _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
    print('Got link while app is running: $uri');
    // TODO: Implement navigation based on the link.
  });

  // Get the initial link that the app was opened with
  final initialUri = await _appLinks.getInitialAppLink();
  if (initialUri != null) {
    print('Initial link: $initialUri');
    // TODO: Implement navigation based on the link.
  }
}
