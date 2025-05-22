import '../../../data/models/vocabulary_bloc_local.dart';

abstract class VocabulairesEvent {}

class LoadVocabulairesData extends VocabulairesEvent {
  final VocabularyBlocLocal data;

  LoadVocabulairesData(this.data);
}

class getAllVocabulaire extends VocabulairesEvent {
  late bool isVocabularyNotLearned;
  late String guidListPerso;
  getAllVocabulaire(this.isVocabularyNotLearned, this.guidListPerso);
}

class GetVocabulaireList extends VocabulairesEvent {
  final bool  isVocabularyNotLearned;
  final String? guidVocabulaire;
  final int? vocabulaireBegin;
  final int? vocabulaireEnd;
  final String? guidListPerso;
  final String titleList;

  GetVocabulaireList({
    this.isVocabularyNotLearned = false,
    this.guidVocabulaire,
    this.vocabulaireBegin,
    this.vocabulaireEnd,
    this.guidListPerso,
    required this.titleList
  });
}
