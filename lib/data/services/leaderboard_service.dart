import 'package:dio/dio.dart';

import '../../core/utils/logger.dart';
import '../../global.dart';
import '../models/leaderboard_user.dart';

class LeaderboardService {
  LeaderboardService();
  final Dio _dio = Dio();
  Future<List<LeaderboardUser>> fetchTopUsers() async {

    Logger.Pink.log('fetchTopUsers: $serverLeaderBoardUrl');
    try {
      final response = await _dio.get(serverLeaderBoardUrl);
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> rawUserList = response.data;


        Logger.Blue.log("rawUserList: $rawUserList");
        return rawUserList.asMap().entries.map((entry) {
              int rank = entry.key + 1; // index 0 -> rank 1, etc.
              Map<String, dynamic> userJson = entry.value;
              userJson['rank'] = rank;
              return LeaderboardUser.fromJson(userJson);
            }).toList();

      } else {
        throw Exception('Échec du chargement du top 3');
      }
    } on DioException catch (e) {
      Logger.Red.log('DioException dans fetchTop3Users: $e');
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      Logger.Red.log('Erreur de parsing dans fetchTop3Users: $e');
      throw Exception('Erreur lors du traitement des données.');
    }
  }

  Future<int> fetchUserRank({required String uid}) async {
    try {
      final response = await _dio.get('$serverRankCurrentUser/$uid');
      if (response.statusCode == 200 && response.data is Map) {
        return response.data['rank'] as int;
      } else {
        throw Exception('Échec du chargement du rang de l\'utilisateur');
      }
    } on DioException catch (e) {
      Logger.Red.log('DioException dans fetchUserRank: $e');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

}
