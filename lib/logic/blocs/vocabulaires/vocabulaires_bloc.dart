import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/vocabulary_bloc_local.dart';
import '../../../data/repository/vocabulaire_repository.dart';
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
        emit(VocabulairesError("Error adding list: $e"));
      }
    });
    on<getAllVocabulaire>(_onAllVocabulaire);
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
}
