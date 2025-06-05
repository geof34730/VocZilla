import '../../../data/models/vocabulary_bloc_local.dart';

abstract class VocabulairesEvent {}

class LoadVocabulairesData extends VocabulairesEvent {
  final VocabularyBlocLocal data;

  LoadVocabulairesData(this.data);
}

class getAllVocabulaire extends VocabulairesEvent {
  late bool isVocabularyNotLearned;
  late String guid;
  getAllVocabulaire(this.isVocabularyNotLearned, this.guid);
}

class GetVocabulaireList extends VocabulairesEvent {
  final bool  isVocabularyNotLearned;
  final String? guidVocabulaire;
  final int? vocabulaireBegin;
  final int? vocabulaireEnd;
  final String? guid;
  final String titleList;
  final bool isListPerso;
  final bool isListTheme;


  GetVocabulaireList({
    this.isVocabularyNotLearned = false,
    this.guidVocabulaire,
    this.vocabulaireBegin,
    this.vocabulaireEnd,
    this.guid,
    required this.titleList,
    required this.isListPerso,
    required this.isListTheme
  });
}
