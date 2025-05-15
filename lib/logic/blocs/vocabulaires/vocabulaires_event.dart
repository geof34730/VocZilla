import '../../../data/models/vocabulary_bloc_local.dart';

abstract class VocabulairesEvent {}

class LoadVocabulairesData extends VocabulairesEvent {
  final VocabularyBlocLocal data;

  LoadVocabulairesData(this.data);
}

