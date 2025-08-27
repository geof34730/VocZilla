import '../../../data/models/vocabulary_bloc_local.dart';

abstract class VocabulairesEvent {}

class LoadVocabulairesData extends VocabulairesEvent {
  final VocabularyBlocLocal data;
  LoadVocabulairesData({required this.data});
}

class getAllVocabulaire extends VocabulairesEvent {
  late bool isVocabularyNotLearned;
  late String guid;
  late String local;
  getAllVocabulaire({ required this.isVocabularyNotLearned, required this.guid, required this.local});
}

class LocaleChangedVocabulaires extends VocabulairesEvent {
  final String local;
  LocaleChangedVocabulaires({required this.local});


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
  final String local;


  GetVocabulaireList({
    this.isVocabularyNotLearned = false,
    this.guidVocabulaire,
    this.vocabulaireBegin,
    this.vocabulaireEnd,
    this.guid,
    required this.titleList,
    required this.isListPerso,
    required this.isListTheme,
    required this.local

  });
}
