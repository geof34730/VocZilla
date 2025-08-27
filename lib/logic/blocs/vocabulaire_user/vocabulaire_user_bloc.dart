// lib/logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/models/vocabulary_user.dart';
import 'package:vobzilla/data/repository/vocabulaire_user_repository.dart';
import 'package:vobzilla/logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import 'package:vobzilla/logic/blocs/vocabulaire_user/vocabulaire_user_state.dart' hide VocabulaireUserUpdate;
import '../../../core/utils/logger.dart';

class VocabulaireUserBloc extends Bloc<VocabulaireUserEvent, VocabulaireUserState> {
  final VocabulaireUserRepository _vocabulaireUserRepository = VocabulaireUserRepository();
  VocabulaireUserState? _lastStateBeforeError;
  VocabulaireUserBloc() : super(VocabulaireUserInitial()) {
    on<VocabulaireUserEvent>((event, emit) {
      Logger.Blue.log("VocabulaireUserBloc - Event: $event, Current State: $state");
    });
    on<CheckVocabulaireUserStatus>(_onCheckVocabulaireUserStatus);
    on<LoadVocabulaireUserData>(_onLoadVocabulaireUserData);
    on<DeleteListPerso>(_onDeleteListPerso);
    on<AddListPerso>(_onAddListPerso);
    on<UpdateListPerso>(_onUpdateListPerso);
    on<AddVocabulaireListPerso>(_onAddVocabulaireListPerso);
    on<DeleteVocabulaireListPerso>(_onDeleteVocabulaireListPerso);
    on<VocabulaireUserBlocErrorCleared>(_onVocabulaireUserBlocErrorCleared);
    on<VocabulaireUserUpdate>((event, emit) {
      Logger.Blue.log('VocabulaireUserBloc - Traitement de VocabulaireUserUpdate');
      emit(VocabulaireUserLoading());
      // Convertir Map<String, dynamic> en VocabulaireUser
      final vocabulaireUser = VocabulaireUser.fromJson(event.userData);
      emit(VocabulaireUserLoaded(vocabulaireUser));
    });


  }
  void _onVocabulaireUserBlocErrorCleared(VocabulaireUserBlocErrorCleared event, Emitter<VocabulaireUserState> emit,) {
      if (state is VocabulaireUserError) {
        if (_lastStateBeforeError != null) {
          emit(_lastStateBeforeError!);
        } else {
          emit(VocabulaireUserEmpty());
      }
    }
  }
  Future<void> _onCheckVocabulaireUserStatus(
      CheckVocabulaireUserStatus event, Emitter<VocabulaireUserState> emit) async {
    try {
      VocabulaireUser? userData = await _vocabulaireUserRepository.getVocabulaireUserData(local: event.local);
      if (userData != null) {
        emit(VocabulaireUserLoaded(userData));
      } else {
        emit(VocabulaireUserEmpty());
      }
    } catch (e) {
      emit(VocabulaireUserError("vocabulaire_user_error_user_data_not_found"));
    }
  }

  Future<void> _onLoadVocabulaireUserData(
      LoadVocabulaireUserData event, Emitter<VocabulaireUserState> emit) async {
    emit(VocabulaireUserLoading());
    try {
      emit(VocabulaireUserLoaded(event.data));
    } catch (e) {
      Logger.Red.log("VocabulaireUserError lors du chargement : $e");
      emit(VocabulaireUserError("vocabulaire_user_error_user_data_not_found"));
    }
  }

  Future<void> _onDeleteListPerso(
      DeleteListPerso event, Emitter<VocabulaireUserState> emit) async {
    try {
      await _vocabulaireUserRepository.deleteListPerso(guid: event.listPersoGuid);
      emit(ListPersoDeletionSuccess(event.listPersoGuid));
      add(CheckVocabulaireUserStatus(local: event.local));
    } catch (e) {
      emit(VocabulaireUserError("vocabulaire_user_error_delete_list"));
    }
  }

  /// Gère l'ajout d'une nouvelle liste personnelle.
  Future<void> _onAddListPerso(
      AddListPerso event, Emitter<VocabulaireUserState> emit) async {
    try {
      await _vocabulaireUserRepository.addListPerso(listPerso: event.listPerso, local: event.local);
      // Rafraîchit les données après l'action
      add(CheckVocabulaireUserStatus(local: event.local));
    } catch (e) {
      emit(VocabulaireUserError("vocabulaire_user_error_add_list_perso"));
    }
  }

  /// Gère la mise à jour d'une liste personnelle.
  Future<void> _onUpdateListPerso(
      UpdateListPerso event, Emitter<VocabulaireUserState> emit) async {
    try {
      await _vocabulaireUserRepository.updateListPerso(listPerso: event.listPerso, local: event.local);
      // Rafraîchit les données après l'action
      add(CheckVocabulaireUserStatus(local: event.local));
    } catch (e) {
      emit(VocabulaireUserError("vocabulaire_user_error_update_list_perso"));
    }
  }

  /// Gère l'ajout d'un mot de vocabulaire à une liste personnelle.
  Future<void> _onAddVocabulaireListPerso(
      AddVocabulaireListPerso event, Emitter<VocabulaireUserState> emit) async {
    try {
      await _vocabulaireUserRepository.addVocabulaireListPerso(
          guidListPerso: event.guidListPerso,
          guidVocabulaire: event.guidVocabulaire,
          local: event.local
      );
      // Rafraîchit les données après l'action
      add(CheckVocabulaireUserStatus(local: event.local));
    } catch (e) {
      emit(VocabulaireUserError("vocabulaire_user_error_add_vocabulaire_list_perso"));
    }
  }

  /// Gère la suppression d'un mot de vocabulaire d'une liste personnelle.
  Future<void> _onDeleteVocabulaireListPerso(
      DeleteVocabulaireListPerso event, Emitter<VocabulaireUserState> emit) async {
    try {
      await _vocabulaireUserRepository.deleteVocabulaireListPerso(
          guidListPerso: event.guidListPerso,
          guidVocabulaire: event.guidVocabulaire,
          local: event.local
      );
      // Rafraîchit les données après l'action
      add(CheckVocabulaireUserStatus(local: event.local));
    } catch (e) {
      emit(VocabulaireUserError("vocabulaire_user_error_add_vocabulaire_list_perso"));
    }
  }
}
