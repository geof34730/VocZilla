import 'dart:convert';

import 'package:http/http.dart' as http;

class VocabulaireServerService {
  final String baseUrl;

  VocabulaireServerService({required this.baseUrl});

  Future<Map<String, dynamic>?> fetchUserData() async {
    final response = await http.get(Uri.parse('$baseUrl/userData'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<void> updateUserData(Map<String, dynamic> userData) async {
    await http.post(
      Uri.parse('$baseUrl/userData'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
  }
}
