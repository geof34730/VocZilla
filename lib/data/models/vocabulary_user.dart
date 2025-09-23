import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'vocabulary_user.freezed.dart';
part 'vocabulary_user.g.dart';

@freezed
abstract class VocabulaireUser with _$VocabulaireUser {
  const factory VocabulaireUser({
    @JsonKey(name: "ListPerso")
    @Default([]) List<ListPerso> listPerso, // MODIFIÉ

    @JsonKey(name: "ListTheme")
    @Default([]) List<ListTheme> listTheme, // MODIFIÉ

    @JsonKey(name: "ListGuidVocabularyLearned")
    @Default([]) List<String> listGuidVocabularyLearned, // MODIFIÉ

    @JsonKey(name: "allListView")
    @Default(true) bool allListView,

    @JsonKey(name: "ListDefinedEnd")
    @Default([]) List<String> ListDefinedEnd, // MODIFIÉ

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
    @JsonKey(name: "ownerUid")
    @Default('') String ownerUid,
    @JsonKey(name: "title")
    @Default('') String title,
    @JsonKey(name: "color")
    required int color,
    @JsonKey(name: "listGuidVocabulary")
    @Default(<String>[]) List<String> listGuidVocabulary, // C'était déjà correct, parfait !
    @JsonKey(name: "isListShare")
    @Default(true) bool isListShare,
    @JsonKey(name: "ownListShare")
    @Default(true) bool ownListShare,
    @JsonKey(name: "urlShare")
    @Default('') String? urlShare,
  }) = _ListPerso;

  factory ListPerso.fromJson(Map<String, dynamic> json) => _$ListPersoFromJson(json);
}


@freezed
abstract class ListTheme with _$ListTheme {
  const factory ListTheme({
    @JsonKey(name: "guid")
    required String guid,
    @JsonKey(name: "title")
    required Map<String, String> title,
    @JsonKey(name: "listGuidVocabulary")
    @Default([]) List<String> listGuidVocabulary, // MODIFIÉ
  }) = _ListTheme;

  factory ListTheme.fromJson(Map<String, dynamic> json) => _$ListThemeFromJson(json);
}


@freezed
abstract class ListDefinedEnd with _$ListDefinedEnd {
  const factory ListDefinedEnd({
    @JsonKey(name: "listName")
    required String listName,
 // MODIFIÉ
  }) = _ListDefinedEnd;

  factory ListDefinedEnd.fromJson(Map<String, dynamic> json) => _$ListDefinedEndFromJson(json);
}
