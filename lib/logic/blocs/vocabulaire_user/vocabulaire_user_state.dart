import 'package:vobzilla/logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';

import '../../../data/models/vocabulary_user.dart';

abstract class VocabulaireUserState {}

class VocabulaireUserInitial extends VocabulaireUserState {}

class VocabulaireUserLoading extends VocabulaireUserState {}

class VocabulaireUserLoaded extends VocabulaireUserState {
  final VocabulaireUser data;
  VocabulaireUserLoaded(this.data);
}

class VocabulaireUserError extends VocabulaireUserState {
  final String error;

  VocabulaireUserError(this.error);
}




class VocabulaireUserUpdate extends VocabulaireUserState {}

