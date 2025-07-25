// lib/logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/models/vocabulary_user.dart';
import 'package:vobzilla/data/repository/vocabulaire_user_repository.dart';
import 'package:vobzilla/logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import 'package:vobzilla/logic/blocs/vocabulaire_user/vocabulaire_user_state.dart' hide VocabulaireUserUpdate;
import '../../../core/utils/logger.dart';

class VocabulaireUserBloc extends Bloc<VocabulaireUserEvent, VocabulaireUserState> {
  final VocabulaireUserRepository _vocabulaireUserRepository = VocabulaireUserRepository();

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
    on<VocabulaireUserUpdate>((event, emit) {
      Logger.Blue.log('VocabulaireUserBloc - Traitement de VocabulaireUserUpdate');
      emit(VocabulaireUserLoading());
      // Convertir Map<String, dynamic> en VocabulaireUser
      final vocabulaireUser = VocabulaireUser.fromJson(event.userData);
      emit(VocabulaireUserLoaded(vocabulaireUser));
    });

  }

  Future<void> _onCheckVocabulaireUserStatus(
      CheckVocabulaireUserStatus event, Emitter<VocabulaireUserState> emit) async {
    try {
      VocabulaireUser? userData = await _vocabulaireUserRepository.getVocabulaireUserData();
      if (userData != null) {
        emit(VocabulaireUserLoaded(userData));
      } else {
        // Il est préférable d'émettre un état "vide" pour le différencier d'une erreur.
        emit(VocabulaireUserEmpty());
      }
    } catch (e) {
      emit(VocabulaireUserError("Erreur lors du chargement des données utilisateur : $e"));
    }
  }

  Future<void> _onLoadVocabulaireUserData(
      LoadVocabulaireUserData event, Emitter<VocabulaireUserState> emit) async {
    emit(VocabulaireUserLoading());
    try {
      emit(VocabulaireUserLoaded(event.data));
    } catch (e) {
      Logger.Red.log("VocabulaireUserError lors du chargement : $e");
      emit(VocabulaireUserError("erreur : $e"));
    }
  }

  Future<void> _onDeleteListPerso(
      DeleteListPerso event, Emitter<VocabulaireUserState> emit) async {
    try {
      await _vocabulaireUserRepository.deleteListPerso(guid: event.listPersoGuid);
      emit(ListPersoDeletionSuccess(event.listPersoGuid));
      add(CheckVocabulaireUserStatus());
    } catch (e) {
      emit(VocabulaireUserError("Erreur lors de la suppression de la liste : $e"));
    }
  }

  /// Gère l'ajout d'une nouvelle liste personnelle.
  Future<void> _onAddListPerso(
      AddListPerso event, Emitter<VocabulaireUserState> emit) async {
    try {
      await _vocabulaireUserRepository.addListPerso(listPerso: event.listPerso);
      // Rafraîchit les données après l'action
      add(CheckVocabulaireUserStatus());
    } catch (e) {
      emit(VocabulaireUserError("Erreur lors de l'ajout de la liste : $e"));
    }
  }

  /// Gère la mise à jour d'une liste personnelle.
  Future<void> _onUpdateListPerso(
      UpdateListPerso event, Emitter<VocabulaireUserState> emit) async {
    try {
      await _vocabulaireUserRepository.updateListPerso(listPerso: event.listPerso);
      // Rafraîchit les données après l'action
      add(CheckVocabulaireUserStatus());
    } catch (e) {
      emit(VocabulaireUserError("Erreur lors de la mise à jour de la liste : $e"));
    }
  }

  /// Gère l'ajout d'un mot de vocabulaire à une liste personnelle.
  Future<void> _onAddVocabulaireListPerso(
      AddVocabulaireListPerso event, Emitter<VocabulaireUserState> emit) async {
    try {
      await _vocabulaireUserRepository.addVocabulaireListPerso(
          guidListPerso: event.guidListPerso, guidVocabulaire: event.guidVocabulaire);
      // Rafraîchit les données après l'action
      add(CheckVocabulaireUserStatus());
    } catch (e) {
      emit(VocabulaireUserError("Erreur lors de l'ajout du vocabulaire à la liste : $e"));
    }
  }

  /// Gère la suppression d'un mot de vocabulaire d'une liste personnelle.
  Future<void> _onDeleteVocabulaireListPerso(
      DeleteVocabulaireListPerso event, Emitter<VocabulaireUserState> emit) async {
    try {
      await _vocabulaireUserRepository.deleteVocabulaireListPerso(
          guidListPerso: event.guidListPerso, guidVocabulaire: event.guidVocabulaire);
      // Rafraîchit les données après l'action
      add(CheckVocabulaireUserStatus());
    } catch (e) {
      emit(VocabulaireUserError("Erreur lors de la suppression du vocabulaire de la liste : $e"));
    }
  }
}
