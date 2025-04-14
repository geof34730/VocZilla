abstract class VocabulairesState {}

class VocabulairesLoading extends VocabulairesState {}

class VocabulairesLoaded extends VocabulairesState {
  final List<dynamic> data;

  VocabulairesLoaded(this.data);
}

class VocabulairesError extends VocabulairesState {}
