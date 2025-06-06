import 'package:firebase_messaging/firebase_messaging.dart';

import '../../core/utils/logger.dart';


class FcmRepository {
  Future<String> geToken() async {
    String token = '';
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      token = fcmToken;
    }
    Logger.Cyan.log("FCM Token: $token");
    return token;
  }

  Future<List<String>> getListFcmToken() async {
    List<String> list = [];
    String token = await geToken();
    list.add(token);
    return list;
  }


  Future<void> deleteTokenFromBackend(String token) async {
    // Implémentez votre logique pour supprimer le token de votre backend
  }


}
