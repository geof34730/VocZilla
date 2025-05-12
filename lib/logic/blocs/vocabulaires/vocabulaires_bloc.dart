import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repository/vocabulaires_repository.dart';
import 'vocabulaires_event.dart';
import 'vocabulaires_state.dart';

class VocabulairesBloc extends Bloc<VocabulairesEvent, VocabulairesState> {
  VocabulairesBloc() : super(VocabulairesLoading()) {
    on<LoadVocabulairesData>((event, emit) async {
      emit(VocabulairesLoading());
      try {
        emit(VocabulairesLoaded(event.data));
      } catch (e) {
        emit(VocabulairesError());
      }
    });
  }


}
