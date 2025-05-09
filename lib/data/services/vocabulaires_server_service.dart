import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/utils/logger.dart';
import '../../global.dart';

class VocabulaireServerService {
  VocabulaireServerService();

  Future<Map<String, dynamic>?> fetchUserData() async {
    final response = await http.get(Uri.parse(serverVocabulaireUserUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<void> updateUserData(Map<String, dynamic> userData) async {
    Logger.Pink.log(userData);
    await http.post(
      Uri.parse(serverVocabulaireUserUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
  }
}
