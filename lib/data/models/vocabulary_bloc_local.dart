import 'package:freezed_annotation/freezed_annotation.dart';

part 'vocabulary_bloc_local.freezed.dart';
part 'vocabulary_bloc_local.g.dart';

@freezed
abstract class VocabularyBlocLocal with _$VocabularyBlocLocal {
  const factory VocabularyBlocLocal({
    required String titleList,
    required List<dynamic> vocabulaireList,
    required int dataAllLength,
    int? vocabulaireBegin,
    int? vocabulaireEnd,
    required bool isListPerso,
    required bool isListTheme,
    String? guid,
    required bool isVocabularyNotLearned,
  }) = _VocabularyBlocLocal;

  factory VocabularyBlocLocal.fromJson(Map<String, dynamic> json) => _$VocabularyBlocLocalFromJson(json);
}
