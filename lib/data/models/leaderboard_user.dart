// lib/data/models/leaderboard_user.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard_user.freezed.dart';
part 'leaderboard_user.g.dart';

@freezed
abstract class LeaderboardUser with _$LeaderboardUser {
  const factory LeaderboardUser({
    // --- Vos champs ---
    required String pseudo,
    required DateTime createdAt,
    required int listPersoCount,
    required String imageAvatar,
    required int countGuidVocabularyLearned,

    // --- Champ ajouté pour le classement ---
    required int rank,
  }) = _LeaderboardUser;

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardUserFromJson(json);
}
