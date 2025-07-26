import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/logger.dart';
import '../models/user_firestore.dart';

class LocalStorageService {
  LocalStorageService._privateConstructor();

  static final LocalStorageService _instance =
  LocalStorageService._privateConstructor();
  factory LocalStorageService() {
    return _instance;
  }

  static const String _userKey = 'current_user';

  /// Sauvegarde l'objet UserFirestore en le convertissant d'abord en String JSON.
  Future<void> saveUser(UserFirestore user) async {
    Logger.Green.log("LocalStorageService saveUser $user");
    try {
      final prefs = await SharedPreferences.getInstance();
      // 1. Convertir l'objet UserFirestore en Map.
      //    (On suppose que toJson() renvoie une Map<String, dynamic>).
      final userMap = user.toJson();
      // 2. Encoder la Map en une chaîne de caractères JSON.
      final userJsonString = jsonEncode(userMap);
      // 3. Sauvegarder la chaîne dans SharedPreferences.
      await prefs.setString(_userKey, userJsonString);
    } catch (e) {
      // Il est préférable d'utiliser un vrai logger ici.
      print('Failed to save user to SharedPreferences: $e');
    }
  }

  /// Charge l'objet UserFirestore à partir d'une String JSON stockée.
  Future<UserFirestore?> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 1. Récupérer la chaîne JSON depuis SharedPreferences.
      final userJsonString = prefs.getString(_userKey);
      if (userJsonString != null) {
        // 2. Décoder la chaîne JSON en une Map.
        final userMap = jsonDecode(userJsonString) as Map<String, dynamic>;
        // 3. Créer l'objet UserFirestore à partir de la Map.
        //    (On suppose que fromJson() attend une Map<String, dynamic>).
        return UserFirestore.fromJson(userMap);
      }
    } catch (e) {
      print('Failed to load user from SharedPreferences: $e');
    }
    return null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {

    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }
}
