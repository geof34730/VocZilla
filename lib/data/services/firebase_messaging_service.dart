import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../core/utils/logger.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> configure() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    Logger.Green.log('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (Platform.isMacOS) {
        await _messaging.getAPNSToken();
      }
      final token = await _messaging.getToken();
      Logger.Yellow.log("FirebaseMessaging.instance.getToken : $token");
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger.Yellow.log('Got a message whilst in the foreground!');
      if (message.notification != null) {
        RemoteNotification notification = message.notification!;
        Logger.Yellow.log('Notification Title: ${notification.title}');
        Logger.Yellow.log('Notification Body: ${notification.body}');
        // Call your notification service to show the notification
      }
    });
  }
}
