abstract class VocabulaireUserEvent {}

class LoadUserData extends VocabulaireUserEvent {}

class UpdateUserData extends VocabulaireUserEvent {
  final Map<String, dynamic> userData;

  UpdateUserData(this.userData);
}
