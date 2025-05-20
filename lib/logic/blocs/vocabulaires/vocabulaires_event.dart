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

