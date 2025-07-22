// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaderboardUser _$LeaderboardUserFromJson(Map<String, dynamic> json) =>
    _LeaderboardUser(
      pseudo: json['pseudo'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      listPersoCount: (json['listPersoCount'] as num).toInt(),
      imageAvatar: json['imageAvatar'] as String,
      countGuidVocabularyLearned:
          (json['countGuidVocabularyLearned'] as num).toInt(),
    );

Map<String, dynamic> _$LeaderboardUserToJson(_LeaderboardUser instance) =>
    <String, dynamic>{
      'pseudo': instance.pseudo,
      'createdAt': instance.createdAt.toIso8601String(),
      'listPersoCount': instance.listPersoCount,
      'imageAvatar': instance.imageAvatar,
      'countGuidVocabularyLearned': instance.countGuidVocabularyLearned,
    };
