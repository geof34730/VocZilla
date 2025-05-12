// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistical_length.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StatisticalLength _$StatisticalLengthFromJson(Map<String, dynamic> json) =>
    _StatisticalLength(
      vocabLearnedCount: (json['vocabLearnedCount'] as num).toInt(),
      countVocabulaireAll: (json['countVocabulaireAll'] as num).toInt(),
    );

Map<String, dynamic> _$StatisticalLengthToJson(_StatisticalLength instance) =>
    <String, dynamic>{
      'vocabLearnedCount': instance.vocabLearnedCount,
      'countVocabulaireAll': instance.countVocabulaireAll,
    };
