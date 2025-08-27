import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/logger.dart';
import '../../../data/models/vocabulary_bloc_local.dart';
import '../../../data/models/vocabulary_user.dart';
import '../../../data/repository/vocabulaire_repository.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
import 'vocabulaires_event.dart';
import 'vocabulaires_state.dart';

class VocabulairesBloc extends Bloc<VocabulairesEvent, VocabulairesState> {
  final VocabulaireRepository _vocabulaireRepository =VocabulaireRepository();

  /// Stores the last event that triggered a vocabulary list fetch.
  /// Used to refetch data when the locale changes.
  VocabulairesEvent? _lastVocabulaireFetchEvent;
  VocabulairesBloc() : super(VocabulairesLoading()) {
    on<LoadVocabulairesData>((event, emit) async {
      emit(VocabulairesLoading());
      try {
        emit(VocabulairesLoaded(event.data));
      } catch (e) {
        Logger.Red.log("VocabulaireError: $e");
        emit(VocabulairesError("Error adding list: $e"));
      }
    });
    on<getAllVocabulaire>(_onAllVocabulaire);
    on<GetVocabulaireList>(_onGetVocabulaireList);
    on<LocaleChangedVocabulaires>(_onLocaleChangedVocabulaires);
  }

  Future<void> _onAllVocabulaire(getAllVocabulaire event, Emitter<VocabulairesState> emit) async {
    _lastVocabulaireFetchEvent = event;
    emit(VocabulairesLoading());
    try {
        VocabularyBlocLocal userData = await  _vocabulaireRepository.goVocabulaireAllForListPersoList(
            isVocabularyNotLearned:event.isVocabularyNotLearned,
            guid: event.guid,
            local: event.local
        );
        emit(VocabulairesLoaded(userData));
    } catch (e) {
      emit(VocabulairesError("Error all list: $e"));
    }
  }




  Future<void> _onGetVocabulaireList(GetVocabulaireList event,Emitter<VocabulairesState> emit) async {
    _lastVocabulaireFetchEvent = event;
    try {
      VocabularyBlocLocal updatedUserData =  await _vocabulaireRepository.getVocabulairesList(
          isVocabularyNotLearned:event.isVocabularyNotLearned,
          vocabulaireBegin: event.vocabulaireBegin,
          vocabulaireEnd: event.vocabulaireEnd,
          guid:event.guid,
          isListPerso:event.isListPerso,
          isListTheme:event.isListTheme,
          titleList: (event.titleList ?? '').toUpperCase(),
          local: event.local
      );
      Logger.Red.log("VocabulaireUserLoaded : $updatedUserData ");
      emit(VocabulairesLoaded(updatedUserData));
      } catch (e) {
      emit(VocabulairesError("Error adding list: $e"));
    }
  }

  Future<void> _onLocaleChangedVocabulaires(LocaleChangedVocabulaires event, Emitter<VocabulairesState> emit) async {
    Logger.Red.log("VocabulairesBloc: Changement de langue reçu : ${event.local}");

    if (_lastVocabulaireFetchEvent == null) {
      // Nothing to reload, no fetch has been made yet.
      return;
    }

    emit(VocabulairesLoading());
    try {
      VocabularyBlocLocal data;
      final lastEvent = _lastVocabulaireFetchEvent;

      if (lastEvent is getAllVocabulaire) {
        data = await _vocabulaireRepository.goVocabulaireAllForListPersoList(
          isVocabularyNotLearned: lastEvent.isVocabularyNotLearned,
          guid: lastEvent.guid,
          local: event.local, // Use new locale
        );
      } else if (lastEvent is GetVocabulaireList) {
        data = await _vocabulaireRepository.getVocabulairesList(
          isVocabularyNotLearned: lastEvent.isVocabularyNotLearned,
          vocabulaireBegin: lastEvent.vocabulaireBegin,
          vocabulaireEnd: lastEvent.vocabulaireEnd,
          guid: lastEvent.guid,
          isListPerso: lastEvent.isListPerso,
          isListTheme: lastEvent.isListTheme,
          titleList: (lastEvent.titleList ?? '').toUpperCase(),
          local: event.local, // Use new locale
        );
      } else {
        // This case should not be reached if _lastVocabulaireFetchEvent is handled correctly
        return;
      }
      emit(VocabulairesLoaded(data));
    } catch (e, stack) {
      Logger.Red.log("Erreur lors du rechargement des vocabulaires pour la langue ${event.local} : $e\n$stack");
      emit(VocabulairesError("Error reloading list for new locale: $e"));
    }
  }

}
