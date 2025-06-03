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
/*
class VocabulaireRepository {
  VocabulaireRepository();
  final VocabulaireService _vocabulaireService = VocabulaireService();
  final VocabulaireUserRepository _vocabulaireUserRepository = VocabulaireUserRepository();

   goVocabulaires({isVocabularyNotLearned = false, required BuildContext context, int? vocabulaireBegin, int? vocabulaireEnd, String? guidListPerso, String? guidListTheme, required String titleList }){
     print("goVocabulaires guidListTheme $guidListTheme");
     BlocProvider.of<VocabulairesBloc>(context).add(GetVocabulaireList(
        isVocabularyNotLearned:isVocabularyNotLearned,
        vocabulaireBegin: vocabulaireBegin,
        vocabulaireEnd: vocabulaireEnd,
        guidListPerso:guidListPerso,
        guidListTheme:guidListTheme,
        titleList: titleList.toUpperCase()
    ));
  }

   goVocabulairesWithState({required BuildContext context, required dynamic state, bool isVocabularyNotLearned = false}){
    goVocabulaires(isVocabularyNotLearned: isVocabularyNotLearned,vocabulaireEnd: state.data.vocabulaireEnd,vocabulaireBegin:  state.data.vocabulaireBegin,guidListPerso:  state.data.guidListPerso,context: context,titleList:  state.data.titleList );
  }

   Future<VocabularyBlocLocal> goVocabulaireAllForListPersoList({required bool isVocabularyNotLearned, required String guidListPerso}) async {
      var data = await getDataTop();
      late List<dynamic> listPersoGuidVocabulary=[];
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

   Future<VocabularyBlocLocal> getVocabulairesList({String? guidListPerso,String? guidListTheme, int? vocabulaireBegin, int? vocabulaireEnd, required String titleList,isVocabularyNotLearned=false}) async {
     //ICI ADD FIELD IsLearnerd
      Logger.Pink.log("getVocabulairesList with theme: $guidListTheme");
      late VocabularyBlocLocal dataSliceWithTitle;
      var data =  await getDataTop();

      final List<dynamic> learnedVocabularies = await _vocabulaireUserRepository.getVocabulaireUserDataLearned(vocabulaireSpecificList: data);
      final Set<String> learnedVocabulariesGuids = learnedVocabularies.map((vocabulaire) => vocabulaire['GUID'] as String).toSet();
      if(guidListPerso!=null){
        VocabulaireUser? userData = await _vocabulaireUserRepository.getVocabulaireUserData();
        ListPerso? listPerso = userData?.listPerso.firstWhere((listPerso) => listPerso.guid == guidListPerso,
          orElse: () => ListPerso(guid: "", title:"",listGuidVocabulary: [], color: 545454),
        );
        final List<dynamic> dataSlice = data.where((vocab) => listPerso != null && listPerso.listGuidVocabulary.contains(vocab['GUID'])).toList();
        final List<dynamic> updatedDataSlice = dataSlice.map((vocabulaire) {
          return {
            ...vocabulaire as Map<String, dynamic>,
            'isLearned': learnedVocabulariesGuids.contains(vocabulaire['GUID']),
          };
        }).toList();
        dataSliceWithTitle = VocabularyBlocLocal(
          titleList: titleList,
          vocabulaireList: updatedDataSlice,
          dataAllLength: updatedDataSlice.length,
          isVocabularyNotLearned: isVocabularyNotLearned,
          isListPerso: true,
          guidListPerso: listPerso?.guid,
        );
      } else if(guidListTheme!=null) {
          Logger.Yellow.log("go guidListTheme: $guidListTheme");
          VocabulaireUser? userData = await _vocabulaireUserRepository.getVocabulaireUserData();
          ListTheme? listTheme = userData?.listTheme.firstWhere((listTheme) => listTheme.guid == guidListTheme,
            orElse: () => ListTheme(guid: "", title: List.empty(), listGuidVocabulary: []),
          );


          Logger.Blue.log(listTheme);

          final List<dynamic> dataSlice = data.where((vocab) => listTheme != null && listTheme.listGuidVocabulary.contains(vocab['GUID'])).toList();

          Logger.Blue.log(dataSlice);


          final List<dynamic> updatedDataSlice = dataSlice.map((vocabulaire) {
            return {
              ...vocabulaire as Map<String, dynamic>,
              'isLearned': learnedVocabulariesGuids.contains(vocabulaire['GUID']),
            };
          }).toList();
          dataSliceWithTitle = VocabularyBlocLocal(
            titleList: titleList,
            vocabulaireList: updatedDataSlice,
            dataAllLength: updatedDataSlice.length,
            isVocabularyNotLearned: isVocabularyNotLearned,
            isListPerso: false,
            //guidListTheme: listTheme?.guid,
          );

          Logger.Blue.log(dataSliceWithTitle);




      }
      else
      {
          final List<dynamic> dataSlice = data.sublist(vocabulaireBegin!, vocabulaireEnd);
          final List<dynamic> updatedDataSlice = dataSlice.map((vocabulaire) {
            return {
              ...vocabulaire as Map<String, dynamic>,
              'isLearned': learnedVocabulariesGuids.contains(vocabulaire['GUID']),
            };
          }).toList();

          dataSliceWithTitle = VocabularyBlocLocal(
            titleList: titleList,
            vocabulaireList: updatedDataSlice,
            dataAllLength: updatedDataSlice.length,
            vocabulaireBegin: vocabulaireBegin,
            vocabulaireEnd: vocabulaireEnd,
            isVocabularyNotLearned: isVocabularyNotLearned,
            isListPerso: false,
          );
      }

      if(isVocabularyNotLearned) {
        final dataSliceNotLearned = await _vocabulaireUserRepository.getVocabulaireUserDataNotLearned(vocabulaireSpecificList: dataSliceWithTitle.vocabulaireList,);
        final VocabularyBlocLocal updatedBlocLocal = dataSliceWithTitle.copyWith(
          vocabulaireList: dataSliceNotLearned,
        );
        dataSliceWithTitle=updatedBlocLocal;
      }
      Logger.Yellow.log(dataSliceWithTitle);
      return dataSliceWithTitle;
  }

   Future<List<dynamic>> getDataTop(){
      var dataAll=_vocabulaireService.getAllData();
      return dataAll;
   }

}
*/

