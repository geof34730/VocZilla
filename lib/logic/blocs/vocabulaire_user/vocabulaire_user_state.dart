import '../../../data/models/vocabulary_user.dart';

abstract class VocabulaireUserState {}

class VocabulaireUserInitial extends VocabulaireUserState {}

class VocabulaireUserLoading extends VocabulaireUserState {}

class VocabulaireUserLoaded extends VocabulaireUserState {
  final VocabulaireUser userData;

  VocabulaireUserLoaded(this.userData);
}

class VocabulaireUserError extends VocabulaireUserState {
  final String message;

  VocabulaireUserError(this.message);
}
