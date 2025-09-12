// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VocabulaireUser _$VocabulaireUserFromJson(Map<String, dynamic> json) =>
    _VocabulaireUser(
      listPerso:
          (json['ListPerso'] as List<dynamic>?)
              ?.map((e) => ListPerso.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      listTheme:
          (json['ListTheme'] as List<dynamic>?)
              ?.map((e) => ListTheme.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      listGuidVocabularyLearned:
          (json['ListGuidVocabularyLearned'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      allListView: json['allListView'] as bool? ?? true,
      ListDefinedEnd:
          (json['ListDefinedEnd'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      countVocabulaireAll: (json['CountVocabulaireAll'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$VocabulaireUserToJson(_VocabulaireUser instance) =>
    <String, dynamic>{
      'ListPerso': instance.listPerso,
      'ListTheme': instance.listTheme,
      'ListGuidVocabularyLearned': instance.listGuidVocabularyLearned,
      'allListView': instance.allListView,
      'ListDefinedEnd': instance.ListDefinedEnd,
      'CountVocabulaireAll': instance.countVocabulaireAll,
    };

_ListPerso _$ListPersoFromJson(Map<String, dynamic> json) => _ListPerso(
  guid: json['guid'] as String,
  title: json['title'] as String,
  color: (json['color'] as num).toInt(),
  listGuidVocabulary:
      (json['listGuidVocabulary'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  isListShare: json['isListShare'] as bool? ?? true,
  ownListShare: json['ownListShare'] as bool? ?? true,
  urlShare: json['urlShare'] as String? ?? '',
);

Map<String, dynamic> _$ListPersoToJson(_ListPerso instance) =>
    <String, dynamic>{
      'guid': instance.guid,
      'title': instance.title,
      'color': instance.color,
      'listGuidVocabulary': instance.listGuidVocabulary,
      'isListShare': instance.isListShare,
      'ownListShare': instance.ownListShare,
      'urlShare': instance.urlShare,
    };

_ListTheme _$ListThemeFromJson(Map<String, dynamic> json) => _ListTheme(
  guid: json['guid'] as String,
  title: Map<String, String>.from(json['title'] as Map),
  listGuidVocabulary:
      (json['listGuidVocabulary'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$ListThemeToJson(_ListTheme instance) =>
    <String, dynamic>{
      'guid': instance.guid,
      'title': instance.title,
      'listGuidVocabulary': instance.listGuidVocabulary,
    };

_ListDefinedEnd _$ListDefinedEndFromJson(Map<String, dynamic> json) =>
    _ListDefinedEnd(listName: json['listName'] as String);

Map<String, dynamic> _$ListDefinedEndToJson(_ListDefinedEnd instance) =>
    <String, dynamic>{'listName': instance.listName};
