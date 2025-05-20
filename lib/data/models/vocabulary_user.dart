import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'vocabulary_user.freezed.dart';
part 'vocabulary_user.g.dart';

@freezed
abstract class VocabulaireUser with _$VocabulaireUser {
  const factory VocabulaireUser({
    @JsonKey(name: "ListPerso")
    required List<ListPerso> listPerso,
    @JsonKey(name: "ListTheme")
    required List<ListTheme> listTheme,
    @JsonKey(name: "ListGuidVocabularyLearned")
    required List<String> listGuidVocabularyLearned,
    @JsonKey(name: "CountVocabulaireAll", defaultValue: 0)
    required int countVocabulaireAll,
  }) = _VocabulaireUser;

  factory VocabulaireUser.fromJson(Map<String, dynamic> json) => _$VocabulaireUserFromJson(json);
}

@freezed
abstract class ListPerso with _$ListPerso {
  const factory ListPerso({
    @JsonKey(name: "guid")
    required String guid,
    @JsonKey(name: "title")
    required String title,
    @JsonKey(name: "color")
    required int color,
    @JsonKey(name: "listGuidVocabulary")
    @Default(<String>[]) List<String> listGuidVocabulary,
    @JsonKey(name: "isListShare")
    @Default(true) bool isListShare,
    @JsonKey(name: "ownListShare")
    @Default(true) bool ownListShare,
    @JsonKey(name: "urlShare")
    @Default('ss') String urlShare,
  }) = _ListPerso;

  factory ListPerso.fromJson(Map<String, dynamic> json) => _$ListPersoFromJson(json);
}


@freezed
abstract class ListTheme with _$ListTheme {
  const factory ListTheme({
    @JsonKey(name: "guid")
    required String guid,
    @JsonKey(name: "title")
    required String title,
    @JsonKey(name: "color")
    required String color,
    @JsonKey(name: "listGuidVocabulary")
    required List<String> listGuidVocabulary,
  }) = _ListTheme;

  factory ListTheme.fromJson(Map<String, dynamic> json) => _$ListThemeFromJson(json);
}
