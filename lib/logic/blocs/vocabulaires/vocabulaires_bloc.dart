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
  }

  Future<void> _onAllVocabulaire(getAllVocabulaire event, Emitter<VocabulairesState> emit) async {
    emit(VocabulairesLoading());
    try {
        VocabularyBlocLocal userData = await  _vocabulaireRepository.goVocabulaireAllForListPersoList(isVocabularyNotLearned:event.isVocabularyNotLearned,guidListPerso: event.guidListPerso);
        emit(VocabulairesLoaded(userData));
    } catch (e) {
      emit(VocabulairesError("Error all list: $e"));
    }
  }

  Future<void> _onGetVocabulaireList(GetVocabulaireList event,Emitter<VocabulairesState> emit) async {
    try {
      VocabularyBlocLocal updatedUserData =  await VocabulaireRepository().getVocabulairesList(
          isVocabularyNotLearned:event.isVocabularyNotLearned,
          vocabulaireBegin: event.vocabulaireBegin,
          vocabulaireEnd: event.vocabulaireEnd,
          guidListPerso:event.guidListPerso,
          titleList: event.titleList.toUpperCase()
      );
      Logger.Red.log("VocabulaireUserLoaded : $updatedUserData ");
      emit(VocabulairesLoaded(updatedUserData));
      } catch (e) {
      emit(VocabulairesError("Error adding list: $e"));
    }
  }


}
