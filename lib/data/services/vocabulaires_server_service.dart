import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/utils/logger.dart';
import '../../global.dart';


class VocabulaireServerService {
  //VocabulaireServerService();
  VocabulaireServerService._privateConstructor();

  static final VocabulaireServerService _instance = VocabulaireServerService._privateConstructor();
  factory VocabulaireServerService() {
    return _instance;
  }

  Future<Map<String, dynamic>?> fetchUserData() async {
    final response = await http.get(Uri.parse(serverVocabulaireUserUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<void> updateUserData(Map<String, dynamic> userData) async {
    Logger.Pink.log(userData);
    // Note: BLoC events should be dispatched from the UI layer, not the service layer
    await http.post(
      Uri.parse(serverVocabulaireUserUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
  }
}
