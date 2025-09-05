// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_bloc_local.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VocabularyBlocLocal _$VocabularyBlocLocalFromJson(Map<String, dynamic> json) =>
    _VocabularyBlocLocal(
      titleList: json['titleList'] as String,
      vocabulaireList: json['vocabulaireList'] as List<dynamic>,
      dataAllLength: (json['dataAllLength'] as num).toInt(),
      vocabulaireBegin: (json['vocabulaireBegin'] as num?)?.toInt(),
      vocabulaireEnd: (json['vocabulaireEnd'] as num?)?.toInt(),
      isListPerso: json['isListPerso'] as bool,
      isListTheme: json['isListTheme'] as bool,
      guid: json['guid'] as String?,
      isVocabularyNotLearned: json['isVocabularyNotLearned'] as bool,
    );

Map<String, dynamic> _$VocabularyBlocLocalToJson(
  _VocabularyBlocLocal instance,
) => <String, dynamic>{
  'titleList': instance.titleList,
  'vocabulaireList': instance.vocabulaireList,
  'dataAllLength': instance.dataAllLength,
  'vocabulaireBegin': instance.vocabulaireBegin,
  'vocabulaireEnd': instance.vocabulaireEnd,
  'isListPerso': instance.isListPerso,
  'isListTheme': instance.isListTheme,
  'guid': instance.guid,
  'isVocabularyNotLearned': instance.isVocabularyNotLearned,
};
