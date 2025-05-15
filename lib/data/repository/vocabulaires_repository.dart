import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/models/vocabulary_user.dart';
import 'package:vobzilla/data/repository/vocabulaire_user_repository.dart';

import '../../core/utils/logger.dart';
import '../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../logic/blocs/vocabulaires/vocabulaires_event.dart';
import '../../ui/screens/vocabulary/list_screen.dart';
import '../models/vocabulary_bloc_local.dart';
import '../services/vocabulaires_service.dart';

class VocabulairesRepository {
  final BuildContext context;
  VocabulairesRepository({required this.context});

  final VocabulaireService _vocabulaireService = VocabulaireService();
   goVocabulairesTop({required int vocabulaireBegin, required int vocabulaireEnd, required String titleList,isVocabularyNotLearned=false}) async {
    var data =  await getDataTop();
    // Tu crées le bloc
    final List<dynamic> dataSlice = data.sublist(vocabulaireBegin, vocabulaireEnd);
    VocabularyBlocLocal dataSliceWithTitle=VocabularyBlocLocal(
        titleList: titleList,
        vocabulaireList: dataSlice,
        dataAllLength: dataSlice.length,
        vocabulaireBegin : vocabulaireBegin,
        vocabulaireEnd :vocabulaireEnd,
        isVocabularyNotLearned:isVocabularyNotLearned
    );

    if(isVocabularyNotLearned) {
      final dataSliceNotLearned = await VocabulaireUserRepository(context: context).getDataNotLearned(vocabulaireSpecificList: dataSliceWithTitle.vocabulaireList,);
      final VocabularyBlocLocal updatedBlocLocal = dataSliceWithTitle.copyWith(
        vocabulaireList: dataSliceNotLearned,
      );
      dataSliceWithTitle=updatedBlocLocal;

      Logger.Pink.log("dataSliceNotLearned: $dataSliceWithTitle");
    }

    // Tu lui passes les data déjà chargées
    context.read<VocabulairesBloc>().add(LoadVocabulairesData(dataSliceWithTitle));
  }

  goVocabulairesThemes() {}

  goVocabulairesPerso() {}

  Future<List<dynamic>> getDataTop(){
    var dataAll=_vocabulaireService.getAllData();
    return dataAll;
  }



}


