import '../../../data/models/vocabulary_bloc_local.dart';

abstract class VocabulairesState {}

class VocabulairesLoading extends VocabulairesState {}

class VocabulairesLoaded extends VocabulairesState {
  final VocabularyBlocLocal data;

  VocabulairesLoaded(this.data);
}

class VocabulairesError extends VocabulairesState {}
