// lib/data/repository/leaderboard_repository.dart
import 'package:vobzilla/data/models/leaderboard_data.dart';
import 'package:vobzilla/data/models/leaderboard_user.dart';
import 'package:vobzilla/data/repository/vocabulaire_user_repository.dart';
import 'package:vobzilla/data/services/leaderboard_service.dart';

class LeaderboardRepository {
  final LeaderboardService _leaderboardService;
  final VocabulaireUserRepository _vocabulaireUserRepository;

  LeaderboardRepository({
    required LeaderboardService leaderboardService,
    required VocabulaireUserRepository vocabulaireUserRepository,
  })  : _leaderboardService = leaderboardService,
        _vocabulaireUserRepository = vocabulaireUserRepository;

  Future<LeaderboardData> fetchLeaderboardData({required String currentUserId}) async {
    try {
      final results = await Future.wait([
        _leaderboardService.fetchTopUsers(),
        _leaderboardService.fetchUserRank(uid: currentUserId),
        _vocabulaireUserRepository.getCountVocabulaireAll()
      ]);

      final topUsers = results[0] as List<LeaderboardUser>;
      final currentUserRank = results[1] as int;
      final totalWords = results[2] as int;
      return LeaderboardData(
        topUsers: topUsers,
        currentUserRank: currentUserRank,
        totalWordsInLevel: totalWords,
      );
    } catch (e, stackTrace) {
      print('Erreur dans le LeaderboardRepository: $e\n$stackTrace');
      rethrow;
    }
  }
}
