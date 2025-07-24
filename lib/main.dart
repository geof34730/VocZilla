import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vobzilla/ui/screens/home_screen.dart';
import 'data/repository/vocabulaire_user_repository.dart';
import 'data/services/firebase_messaging_service.dart';
import 'data/services/notification_service.dart';
import 'firebase_initialiser.dart';
import 'package:vobzilla/app.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

FirebaseMessaging messaging = FirebaseMessaging.instance;

void main({bool shootScreenShot = false,String? localForce=null}) async {
  WidgetsFlutterBinding.ensureInitialized();


  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await FirebaseInitializer.initialize();
  if (!shootScreenShot) {
    final notificationService = NotificationService();
    await notificationService.initialize();

    final messagingService = FirebaseMessagingService();
    await messagingService.configure();
  }

  final vocabulaireUserRepository = VocabulaireUserRepository();
  await vocabulaireUserRepository.updateListTheme();


  runApp(MyApp(localForce:localForce));
}


