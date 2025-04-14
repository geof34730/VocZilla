abstract class VocabulairesEvent {}

class LoadVocabulairesData extends VocabulairesEvent {
  final List<dynamic> data;

  LoadVocabulairesData(this.data);
}
