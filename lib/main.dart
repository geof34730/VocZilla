import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'data/repository/vocabulaire_user_repository.dart';
import 'data/services/firebase_messaging_service.dart';
import 'data/services/notification_service.dart';
import 'firebase_initialiser.dart';
import 'package:vobzilla/app.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import 'logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

FirebaseMessaging messaging = FirebaseMessaging.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final messagingService = FirebaseMessagingService();
  await messagingService.configure();

  final vocabulaireUserRepository = VocabulaireUserRepository();
  await vocabulaireUserRepository.updateListTheme();


  runApp(MyApp());
}


