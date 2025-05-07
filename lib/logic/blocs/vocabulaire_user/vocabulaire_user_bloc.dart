import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import 'package:vobzilla/logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';


import '../../../core/utils/logger.dart';
import '../../../data/models/vocabulary_user.dart';
import '../../../data/repository/vocabulaire_user_repository.dart'; // Assurez-vous d'importer votre modèle

class VocabulaireUserBloc extends Bloc<VocabulaireUserEvent, VocabulaireUserState> {
  final VocabulaireUserRepository repository;

  VocabulaireUserBloc(this.repository) : super(UserDataInitial()) {
    on<LoadUserData>(_onLoadUserData);
    on<UpdateUserData>(_onUpdateUserData);
  }

  Future<void> _onLoadUserData(LoadUserData event,
      Emitter<VocabulaireUserState> emit) async {
    emit(UserDataLoading());
    try {
      final userDataJson = await repository.localStorageService.getUserData();
      if (userDataJson != null) {
        final userData = VocabulaireUser.fromJson(userDataJson);
        emit(UserDataLoaded(userData));
      } else {
        // Create default user data if none exists
        final defaultUserData = VocabulaireUser.fromJson({});
        emit(UserDataLoaded(defaultUserData));
      }
    } catch (e) {
      emit(UserDataError(e.toString()));
    }
  }

  Future<void> _onUpdateUserData(UpdateUserData event,
      Emitter<VocabulaireUserState> emit) async {
        emit(UserDataLoading());
        try {
          Logger.Red.log('UpdateUserData in bloc');
         // await repository.updateUserData(event.userData.toJson());
         // emit(UserDataLoaded(event.userData));
        } catch (e) {
          emit(UserDataError(e.toString()));
        }
  }
}


