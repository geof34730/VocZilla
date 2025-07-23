// lib/data/models/leaderboard_data.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vobzilla/data/models/leaderboard_user.dart'; // Gardez cet import

// Lignes requises par le générateur de code
part 'leaderboard_data.freezed.dart';
part 'leaderboard_data.g.dart';

@freezed
abstract class LeaderboardData with _$LeaderboardData {
  // Le constructeur principal devient un "factory"
  const factory LeaderboardData({
    // Les propriétés ne changent pas
    required List<LeaderboardUser> topUsers,
    required int currentUserRank,
    required int totalWordsInLevel,
  }) = _LeaderboardData;

  /// Factory pour créer une instance à partir d'un JSON.
  /// C'est la manière standard de gérer la désérialisation avec freezed.
  factory LeaderboardData.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardDataFromJson(json);
}
