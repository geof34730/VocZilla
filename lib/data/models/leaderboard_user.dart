// lib/model/leaderboard_user.dart

// NÉCESSAIRE: Import de la librairie freezed
import 'package:freezed_annotation/freezed_annotation.dart';

// NÉCESSAIRE: Directives 'part' pour les fichiers qui seront générés
part 'leaderboard_user.freezed.dart';
part 'leaderboard_user.g.dart';

@freezed

abstract class LeaderboardUser with _$LeaderboardUser {
  // Le constructeur principal est maintenant une factory.
  // C'est ici que vous définissez les propriétés de votre modèle.
  const factory LeaderboardUser({
    required String pseudo,
    required DateTime createdAt,
    required int listPersoCount,
    required String imageAvatar,
    required int countGuidVocabularyLearned,
  }) = _LeaderboardUser;

  // Factory pour la désérialisation JSON.
  // La logique est déléguée au fichier généré.
  factory LeaderboardUser.fromJson(Map<String, dynamic> json) => _$LeaderboardUserFromJson(json);
}
