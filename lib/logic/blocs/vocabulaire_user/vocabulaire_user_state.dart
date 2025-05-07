import '../../../data/models/vocabulary_user.dart';

abstract class VocabulaireUserState {}

class UserDataInitial extends VocabulaireUserState {}

class UserDataLoading extends VocabulaireUserState {}

class UserDataLoaded extends VocabulaireUserState {
  final VocabulaireUser userData;

  UserDataLoaded(this.userData);
}

class UserDataError extends VocabulaireUserState {
  final String message;

  UserDataError(this.message);
}
