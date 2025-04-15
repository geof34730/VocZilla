abstract class VocabulairesEvent {}

class LoadVocabulairesData extends VocabulairesEvent {
  final Map<String, Object> data;

  LoadVocabulairesData(this.data);
}
