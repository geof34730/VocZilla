abstract class VocabulairesState {}

class VocabulairesLoading extends VocabulairesState {}

class VocabulairesLoaded extends VocabulairesState {
  final Map<String, Object> data;

  VocabulairesLoaded(this.data);
}

class VocabulairesError extends VocabulairesState {}
