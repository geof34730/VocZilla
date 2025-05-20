import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/models/vocabulary_user.dart';
import 'package:vobzilla/data/repository/vocabulaire_user_repository.dart';
import 'package:vobzilla/logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import 'package:vobzilla/logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../../../core/utils/logger.dart';
import '../user/user_state.dart';


class VocabulaireUserBloc extends Bloc<VocabulaireUserEvent, VocabulaireUserState> {
  final VocabulaireUserRepository _vocabulaireUserRepository =VocabulaireUserRepository();
  VocabulaireUserBloc() : super(VocabulaireUserInitial()) {
    on<CheckVocabulaireUserStatus>(_onCheckVocabulaireUserStatus);
    on<LoadVocabulaireUserData>((event, emit) async {
      emit(VocabulaireUserLoading());
      try {
        emit(VocabulaireUserLoaded(event.data));
      } catch (e) {
        emit(VocabulaireUserError("erreur : $e"));
      }
    });
    on<DeleteListPerso>(_onDeleteListPerso);
    on<AddListPerso>(_onAddListPerso);
    on<AddVocabulaireListPerso>(_onAddVocabulaireListPerso);
    on<DeleteVocabulaireListPerso>(_onDeleteVocabulaireListPerso);
  }

  Future<void> _onCheckVocabulaireUserStatus(CheckVocabulaireUserStatus event, Emitter<VocabulaireUserState> emit) async {
    try {
      VocabulaireUser? userData =  await VocabulaireUserRepository().getVocabulaireUserData();
      if (userData != null) {
        emit(VocabulaireUserLoaded(userData));
      } else {

        emit(VocabulaireUserError("No user data found."));
      }
    } catch (e) {
      emit(VocabulaireUserError("Error loading user data: $e"));
    }
  }

  Future<void> _onDeleteListPerso(DeleteListPerso event, Emitter<VocabulaireUserState> emit) async {
    try {
      await _vocabulaireUserRepository.deleteListPerso(guid: event.listPersoGuid);
      VocabulaireUser? updatedUserData =  await VocabulaireUserRepository().getVocabulaireUserData();
      if (updatedUserData != null) {
        emit(VocabulaireUserLoaded(updatedUserData));
      } else {
        emit(VocabulaireUserError("Failed to update user data after deletion."));
      }
    } catch (e) {
      emit(VocabulaireUserError("Error deleting list: $e"));
    }
  }

  Future<void> _onAddListPerso(AddListPerso event, Emitter<VocabulaireUserState> emit) async {
    try {
      await _vocabulaireUserRepository.addListPerso(listPerso: event.listPerso);
      VocabulaireUser? updatedUserData = await VocabulaireUserRepository()
          .getVocabulaireUserData();
      if (updatedUserData != null) {
        emit(VocabulaireUserLoaded(updatedUserData));
      } else {
        emit(
            VocabulaireUserError("Failed to update user data after addition."));
      }
    } catch (e) {
      emit(VocabulaireUserError("Error adding list: $e"));
    }
  }

  Future<void> _onAddVocabulaireListPerso(AddVocabulaireListPerso event,Emitter<VocabulaireUserState> emit) async {
    try {
      await _vocabulaireUserRepository.addVocabulaireListPerso(guidListPerso: event.guidListPerso,guidVocabulaire: event.guidVocabulaire);
      VocabulaireUser? updatedUserData = await VocabulaireUserRepository().getVocabulaireUserData();
      if (updatedUserData != null) {
        Logger.Red.log("VocabulaireUserLoaded : $updatedUserData ");
        emit(VocabulaireUserLoaded(updatedUserData));
      } else {
        emit(VocabulaireUserError("Failed to update user data after addition."));
      }
    } catch (e) {
      emit(VocabulaireUserError("Error adding list: $e"));
    }
  }

  Future<void> _onDeleteVocabulaireListPerso(DeleteVocabulaireListPerso event,Emitter<VocabulaireUserState> emit) async {
    try {
      await _vocabulaireUserRepository.deleteVocabulaireListPerso(guidListPerso: event.guidListPerso,guidVocabulaire: event.guidVocabulaire);
      VocabulaireUser? updatedUserData = await VocabulaireUserRepository().getVocabulaireUserData();
      if (updatedUserData != null) {
        Logger.Red.log("VocabulaireUserLoaded : $updatedUserData ");
        emit(VocabulaireUserLoaded(updatedUserData));
      } else {
        emit(VocabulaireUserError("Failed to update user data after addition."));
      }
    } catch (e) {
      emit(VocabulaireUserError("Error adding list: $e"));
    }
  }
}
