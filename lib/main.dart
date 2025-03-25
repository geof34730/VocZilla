import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'data/services/firebase_messaging_service.dart';
import 'data/services/notification_service.dart';
import 'firebase_initialiser.dart';
import 'package:vobzilla/app.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

FirebaseMessaging messaging = FirebaseMessaging.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final messagingService = FirebaseMessagingService();
  await messagingService.configure();

  runApp(MyApp());
}


