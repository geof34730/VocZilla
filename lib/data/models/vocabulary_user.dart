import 'package:freezed_annotation/freezed_annotation.dart';

part 'vocabulary_user.freezed.dart';

part 'vocabulary_user.g.dart'; // Ajoutez ceci si vous utilisez la sérialisation JSON

@freezed
@freezed
class VocabulaireUser with _$VocabulaireUser {
  const factory VocabulaireUser({
    @JsonKey(name: "ListPerso")
    required List<ListPerso> listPerso,
    @JsonKey(name: "ListTheme")
    required List<ListTheme> listTheme,
    @JsonKey(name: "ListGuidVocabularyLearned")
    required List<String> listGuidVocabularyLearned,
  }) = _VocabulaireUser;

  factory VocabulaireUser.fromJson(Map<String, dynamic> json) => _$VocabulaireUserFromJson(json);

  @override
  // TODO: implement listGuidVocabularyLearned
  List<String> get listGuidVocabularyLearned => throw UnimplementedError();

  @override
  // TODO: implement listPerso
  List<ListPerso> get listPerso => throw UnimplementedError();

  @override
  // TODO: implement listTheme
  List<ListTheme> get listTheme => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

@freezed
class ListPerso with _$ListPerso {
  const factory ListPerso({
    @JsonKey(name: "guid")
    required String guid,
    @JsonKey(name: "title")
    required String title,
    @JsonKey(name: "color")
    required String color,
    @JsonKey(name: "listGuidVocabulary")
    required List<String> listGuidVocabulary,
    @JsonKey(name: "isListShare")
    required bool isListShare,
    @JsonKey(name: "ownListShare")
    required bool ownListShare,
    @JsonKey(name: "urlShare")
    required String urlShare,
  }) = _ListPerso;

  factory ListPerso.fromJson(Map<String, dynamic> json) =>
      _$ListPersoFromJson(json);

  @override
  // TODO: implement color
  String get color => throw UnimplementedError();

  @override
  // TODO: implement guid
  String get guid => throw UnimplementedError();

  @override
  // TODO: implement isListShare
  bool get isListShare => throw UnimplementedError();

  @override
  // TODO: implement listGuidVocabulary
  List<String> get listGuidVocabulary => throw UnimplementedError();

  @override
  // TODO: implement ownListShare
  bool get ownListShare => throw UnimplementedError();

  @override
  // TODO: implement title
  String get title => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  // TODO: implement urlShare
  String get urlShare => throw UnimplementedError();
}

@freezed
class ListTheme with _$ListTheme {
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

  factory ListTheme.fromJson(Map<String, dynamic> json) =>
      _$ListThemeFromJson(json);

  @override
  // TODO: implement color
  String get color => throw UnimplementedError();

  @override
  // TODO: implement guid
  String get guid => throw UnimplementedError();

  @override
  // TODO: implement listGuidVocabulary
  List<String> get listGuidVocabulary => throw UnimplementedError();

  @override
  // TODO: implement title
  String get title => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
