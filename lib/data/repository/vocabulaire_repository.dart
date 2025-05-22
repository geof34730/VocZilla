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
  final VocabulaireUserRepository _vocabulaireUserRepository = VocabulaireUserRepository();

  goVocabulaires({isVocabularyNotLearned = false, required BuildContext context, int? vocabulaireBegin, int? vocabulaireEnd, String? guidListPerso, required String titleList }){
    BlocProvider.of<VocabulairesBloc>(context).add(GetVocabulaireList(
        isVocabularyNotLearned:isVocabularyNotLearned,
        vocabulaireBegin: vocabulaireBegin,
        vocabulaireEnd: vocabulaireEnd,
        guidListPerso:guidListPerso,
        titleList: titleList.toUpperCase()
    ));
  }

  goVocabulairesWithStata({required BuildContext context, required dynamic state, bool isVocabularyNotLearned = false}){
    goVocabulaires(isVocabularyNotLearned: isVocabularyNotLearned,vocabulaireEnd: state.data.vocabulaireEnd,vocabulaireBegin:  state.data.vocabulaireBegin,guidListPerso:  state.data.guidListPerso,context: context,titleList:  state.data.titleList );
  }

   Future<VocabularyBlocLocal> goVocabulaireAllForListPersoList({required bool isVocabularyNotLearned, required String guidListPerso}) async {
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
        isListPerso: true,
        guidListPerso:guidListPerso
      );
      if(isVocabularyNotLearned) {
        final dataSliceNotLearned = await _vocabulaireUserRepository.getVocabulaireUserDataNotLearned(vocabulaireSpecificList: dataSliceWithTitle.vocabulaireList,);
        final VocabularyBlocLocal updatedBlocLocal = dataSliceWithTitle.copyWith(
          vocabulaireList: dataSliceNotLearned,
        );
        dataSliceWithTitle=updatedBlocLocal;
      }

      return dataSliceWithTitle;
    }

   Future<VocabularyBlocLocal> getVocabulairesList({String? guidListPerso, int? vocabulaireBegin, int? vocabulaireEnd, required String titleList,isVocabularyNotLearned=false}) async {
      Logger.Pink.log("getVocabulairesList: $guidListPerso");
      late VocabularyBlocLocal dataSliceWithTitle;
      var data =  await getDataTop();
      if(guidListPerso!=null){
        VocabulaireUser? userData = await _vocabulaireUserRepository.getVocabulaireUserData();
        ListPerso? listPerso = userData?.listPerso.firstWhere((listPerso) => listPerso.guid == guidListPerso,
          orElse: () => ListPerso(guid: "", title:"",listGuidVocabulary: [], color: 545454),
        );

        final List<dynamic> dataSlice = data.where((vocab) => listPerso != null && listPerso.listGuidVocabulary.contains(vocab['GUID'])).toList();
            dataSliceWithTitle = VocabularyBlocLocal(
                titleList: titleList,
                vocabulaireList: dataSlice,
                dataAllLength: dataSlice.length,
                isVocabularyNotLearned: isVocabularyNotLearned,
                isListPerso: true,
                guidListPerso: listPerso?.guid
            );
      }
      else{
            final List<dynamic> dataSlice = data.sublist(vocabulaireBegin!, vocabulaireEnd);
            dataSliceWithTitle = VocabularyBlocLocal(
                titleList: titleList,
                vocabulaireList: dataSlice,
                dataAllLength: dataSlice.length,
                vocabulaireBegin: vocabulaireBegin,
                vocabulaireEnd: vocabulaireEnd,
                isVocabularyNotLearned: isVocabularyNotLearned,
                isListPerso: false
            );
      }
      if(isVocabularyNotLearned) {
        final dataSliceNotLearned = await _vocabulaireUserRepository.getVocabulaireUserDataNotLearned(vocabulaireSpecificList: dataSliceWithTitle.vocabulaireList,);
        final VocabularyBlocLocal updatedBlocLocal = dataSliceWithTitle.copyWith(
          vocabulaireList: dataSliceNotLearned,
        );
        dataSliceWithTitle=updatedBlocLocal;
      }
      return dataSliceWithTitle;
  }

   Future<List<dynamic>> getDataTop(){
      var dataAll=_vocabulaireService.getAllData();
      return dataAll;
    }

}


