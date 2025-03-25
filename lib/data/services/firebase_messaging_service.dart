import 'package:firebase_messaging/firebase_messaging.dart';

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

    print('User granted permission: ${settings.authorizationStatus}');

    _messaging.getToken().then((value) => print("FirebaseMessaging.instance.getToken : $value"));

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      if (message.notification != null) {
        RemoteNotification notification = message.notification!;
        print('Notification Title: ${notification.title}');
        print('Notification Body: ${notification.body}');
        // Call your notification service to show the notification
      }
    });
  }
}
