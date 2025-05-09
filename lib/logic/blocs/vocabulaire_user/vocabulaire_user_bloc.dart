import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import 'package:vobzilla/logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';


import '../../../core/utils/logger.dart';
import '../../../data/models/vocabulary_user.dart';
import '../../../data/repository/vocabulaire_user_repository.dart'; // Assurez-vous d'importer votre modèle

class VocabulaireUserBloc extends Bloc<VocabulaireUserEvent, VocabulaireUserState> {
  final VocabulaireUserRepository repository;

  VocabulaireUserBloc(this.repository) : super(VocabulaireUserInitial()) {
    on<LoadVocabulaireUserData>(_onLoadUserData);
    on<UpdateVocabulaireUserData>(_onUpdateUserData);
  }

  Future<void> _onLoadUserData(
      LoadVocabulaireUserData event, Emitter<VocabulaireUserState> emit) async {
    emit(VocabulaireUserLoading());
    try {
      final userData = await repository.getUserData();
      if (userData != null) {
        emit(VocabulaireUserLoaded(userData));
      } else {
        emit(VocabulaireUserError('Échec du chargement des données utilisateur'));
      }
    } catch (e) {
      emit(VocabulaireUserError(e.toString()));
    }
  }

  Future<void> _onUpdateUserData(
      UpdateVocabulaireUserData event, Emitter<VocabulaireUserState> emit) async {
    emit(VocabulaireUserLoading());
    try {
      await repository.updateUserData(event.userData);
      emit(VocabulaireUserLoaded(event.userData));
    } catch (e) {
      emit(VocabulaireUserError(e.toString()));
    }
  }
}




