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

class VocabulaireRepository {

  VocabulaireRepository();

  final VocabulaireService _vocabulaireService = VocabulaireService();


    Future<VocabularyBlocLocal> goVocabulaireAllForListPersoList({required bool isVocabularyNotLearned, required String guidListPerso}) async {
      VocabulaireUserRepository _vocabulaireUserRepository = VocabulaireUserRepository();
      var data = await getDataTop();
      late List<dynamic> listPersoGuidVocabulary=[];
      Logger.Yellow.log("guidListPerso: $guidListPerso");
      final List<dynamic> dataSlice = data;
      final List<dynamic> learnedVocabularies = await _vocabulaireUserRepository.getVocabulaireUserDataLearned(vocabulaireSpecificList: dataSlice);
      final Set<String> learnedVocabulariesGuids = learnedVocabularies.map((vocabulaire) => vocabulaire['GUID'] as String).toSet();
      VocabulaireUser? userData =  await _vocabulaireUserRepository.getVocabulaireUserData();

      if (userData != null) {
         listPersoGuidVocabulary = userData.listPerso.firstWhere((listPerso) => listPerso.guid == guidListPerso).listGuidVocabulary;
        //selectedVocabularies = listPerso.vocabulaireGuid ?? [];
        Logger.Yellow.log("listPerso.listGuidVocabulary: ${listPersoGuidVocabulary}");
      }

      final List<dynamic> updatedDataSlice = dataSlice.map((vocabulaire) {
        return {
          ...vocabulaire as Map<String, dynamic>,
          'isLearned': learnedVocabulariesGuids.contains(vocabulaire['GUID']),
          'isSelectedInListPerso': listPersoGuidVocabulary.contains(vocabulaire['GUID'])
        };
      }).toList();

      List<dynamic> valuesList = updatedDataSlice;

      VocabularyBlocLocal dataSliceWithTitle = VocabularyBlocLocal(
        titleList: "",
        vocabulaireList: valuesList,
        dataAllLength: valuesList.length,
        vocabulaireBegin: 0,
        vocabulaireEnd: valuesList.length,
        isVocabularyNotLearned: isVocabularyNotLearned,
      );
      if(isVocabularyNotLearned) {
        final dataSliceNotLearned = await VocabulaireUserRepository().getVocabulaireUserDataNotLearned(vocabulaireSpecificList: dataSliceWithTitle.vocabulaireList,);
        final VocabularyBlocLocal updatedBlocLocal = dataSliceWithTitle.copyWith(
          vocabulaireList: dataSliceNotLearned,
        );
        dataSliceWithTitle=updatedBlocLocal;
      }

      return dataSliceWithTitle;
    }

    goVocabulairesTop({required int vocabulaireBegin, required int vocabulaireEnd, required String titleList,isVocabularyNotLearned=false, required BuildContext context}) async {
      var data =  await getDataTop();
      Logger.Yellow.log("getDataTop() : $data");
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
      final dataSliceNotLearned = await VocabulaireUserRepository().getVocabulaireUserDataNotLearned(vocabulaireSpecificList: dataSliceWithTitle.vocabulaireList,);
      final VocabularyBlocLocal updatedBlocLocal = dataSliceWithTitle.copyWith(
        vocabulaireList: dataSliceNotLearned,
      );
      dataSliceWithTitle=updatedBlocLocal;

      Logger.Pink.log("dataSliceNotLearned: $dataSliceWithTitle");
    }
    Logger.Yellow.log("getDataTop() final : $dataSliceWithTitle");
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


