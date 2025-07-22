// lib/data/repositories/leaderboard_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../global.dart';
import '../models/leaderboard_user.dart'; // Assurez-vous que le chemin est correct

class LeaderboardRepository {

  Future<List<LeaderboardUser>> fetchTop3() async {
    final response = await http.get(Uri.parse(serverLeaderBoardUrl));

    if (response.statusCode == 200) {
      // Si le serveur retourne une réponse 200 OK, on parse le JSON.
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => LeaderboardUser.fromJson(json)).toList();
    } else {
      // Si la réponse n'est pas OK, on lève une exception.
      throw Exception('Failed to load leaderboard');
    }
  }
}
