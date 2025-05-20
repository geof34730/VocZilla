import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {

  LocalStorageService._privateConstructor();

  static final LocalStorageService _instance = LocalStorageService._privateConstructor();
  factory LocalStorageService() {
    return _instance;
  }



  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userData', jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }









}
