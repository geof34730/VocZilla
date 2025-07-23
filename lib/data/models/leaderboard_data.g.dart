// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaderboardData _$LeaderboardDataFromJson(Map<String, dynamic> json) =>
    _LeaderboardData(
      topUsers: (json['topUsers'] as List<dynamic>)
          .map((e) => LeaderboardUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentUserRank: (json['currentUserRank'] as num).toInt(),
      totalWordsInLevel: (json['totalWordsInLevel'] as num).toInt(),
    );

Map<String, dynamic> _$LeaderboardDataToJson(_LeaderboardData instance) =>
    <String, dynamic>{
      'topUsers': instance.topUsers,
      'currentUserRank': instance.currentUserRank,
      'totalWordsInLevel': instance.totalWordsInLevel,
    };
