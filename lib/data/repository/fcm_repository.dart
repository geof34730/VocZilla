



import 'package:firebase_messaging/firebase_messaging.dart';

class FcmRepository {
  Future<String> geToken() async {
    String token = '';
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      token = fcmToken;
    }
    print("FCM Token: $token");
    return token;
  }

}
