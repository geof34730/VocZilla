import '../../../data/models/vocabulary_user.dart';

abstract class VocabulaireUserEvent {}

class LoadVocabulaireUserData extends VocabulaireUserEvent {}

class UpdateVocabulaireUserData extends VocabulaireUserEvent {
  final VocabulaireUser userData;

  UpdateVocabulaireUserData(this.userData);
}
