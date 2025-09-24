import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/data/models/vocabulary_user.dart';
import 'package:voczilla/data/repository/vocabulaire_user_repository.dart';

import '../../core/utils/logger.dart';
import '../../global.dart';
import '../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../logic/blocs/vocabulaires/vocabulaires_event.dart';
import '../../ui/screens/vocabulary/list_screen.dart';
import '../models/vocabulary_bloc_local.dart';
import '../services/vocabulaires_service.dart';

class VocabulaireRepository {
  VocabulaireRepository();
  final VocabulaireService _vocabulaireService = VocabulaireService();
  final VocabulaireUserRepository _vocabulaireUserRepository = VocabulaireUserRepository();

   goVocabulaires({isVocabularyNotLearned = false,required String local,required bool isListPerso, required bool isListTheme, required String? guid, required BuildContext context, int? vocabulaireBegin, int? vocabulaireEnd,  required String titleList }){
      BlocProvider.of<VocabulairesBloc>(context).add(GetVocabulaireList(
          isVocabularyNotLearned:isVocabularyNotLearned,
          vocabulaireBegin: vocabulaireBegin,
          vocabulaireEnd: vocabulaireEnd,
          guid:guid,
          isListPerso:isListPerso,
          isListTheme:isListTheme,
          titleList: titleList.toUpperCase(),
          local:local
      ));
  }

   goVocabulairesWithState({required BuildContext context, required dynamic state, bool isVocabularyNotLearned = false, required String local}){
       goVocabulaires(
          isVocabularyNotLearned: isVocabularyNotLearned,
          vocabulaireEnd: state.data.vocabulaireEnd,
          vocabulaireBegin:  state.data.vocabulaireBegin,
          guid:  state.data.guid,
          context: context,
          titleList:  state.data.titleList,
          isListTheme: state.data.isListTheme,
          isListPerso: state.data.isListPerso,
          local: local
      );
  }

   Future<VocabularyBlocLocal> goVocabulaireAllForListPersoList({required bool isVocabularyNotLearned, required String guid, required String local}) async {
      var data = await getDataTop(local:local);
      late List<dynamic> listPersoGuidVocabulary=[];
      final List<dynamic> dataSlice = data;
      final List<dynamic> learnedVocabularies = await _vocabulaireUserRepository.getVocabulaireUserDataLearned(vocabulaireSpecificList: dataSlice);
      final Set<String> learnedVocabulariesGuids = learnedVocabularies.map((vocabulaire) => vocabulaire['GUID'] as String).toSet();
      VocabulaireUser? userData =  await _vocabulaireUserRepository.getVocabulaireUserData(local:local);

      if (userData != null) {
         listPersoGuidVocabulary = userData.listPerso.firstWhere((listPerso) => listPerso.guid == guid).listGuidVocabulary;
        //selectedVocabularies = listPerso.vocabulaireGuid ?? [];
      //  Logger.Yellow.log("listPerso.listGuidVocabulary: ${listPersoGuidVocabulary}");
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
        isListTheme: true,
        guid:guid
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

   Future<VocabularyBlocLocal> getVocabulairesList({
     String? guid,
     required bool isListPerso,
     required bool isListTheme,
     required String local,

     int? vocabulaireBegin,
     int? vocabulaireEnd,
     required String titleList,
     isVocabularyNotLearned=false
   }) async {
      late VocabularyBlocLocal dataSliceWithTitle;
      var data =  await getDataTop(local: local);
      final List<dynamic> learnedVocabularies = await _vocabulaireUserRepository.getVocabulaireUserDataLearned(vocabulaireSpecificList: data);
      final Set<String> learnedVocabulariesGuids = learnedVocabularies.map((vocabulaire) => vocabulaire['GUID'] as String).toSet();
      if(isListPerso){
        VocabulaireUser? userData = await _vocabulaireUserRepository.getVocabulaireUserData(local: local);
        ListPerso? listPerso = userData?.listPerso.firstWhere((listPerso) => listPerso.guid == guid,
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
          isListPerso: isListPerso,
          isListTheme: isListTheme,
          guid: guid,
        );
      } else if(isListTheme) {
          VocabulaireUser? userData = await _vocabulaireUserRepository.getVocabulaireUserData(local: local);
          ListTheme? listTheme = userData?.listTheme.firstWhere((listTheme) => listTheme.guid == guid,
            orElse: () => ListTheme(guid: "", title: {"fr" : ""}, listGuidVocabulary: []),
          );

        final List<dynamic> dataSlice = data.where((vocab) => listTheme != null && listTheme.listGuidVocabulary.contains(vocab['GUID'])).toList();

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
            isListPerso: isListPerso,
            isListTheme: isListTheme,
            guid: guid,
            //guidListTheme: listTheme?.guid,
          );
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
            isListPerso: isListPerso,
            isListTheme: isListTheme
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

   Future<List<dynamic>> getDataTop({required String local}){
      var dataAll=_vocabulaireService.getAllData(local: local);
      return dataAll;
   }

  List<Map<String, int>> cartConfigDefined() {
    final List<Map<String, int>> cardConfigs = [
      {'begin': 0, 'end': 20},
      {'begin': 20, 'end': 50},
      {'begin': 50, 'end': 100},
      {'begin': 100, 'end': 200},
      {'begin': 200, 'end': 300},
      {'begin': 300, 'end': 400},
    ];
    // Toujours générer la liste complète des configurations possibles.
    for (int i = 400; i < globalCountVocabulaireAll; i += 100) {
      final int endValue = min(i + 100, globalCountVocabulaireAll);
      cardConfigs.add({'begin': i, 'end': endValue});
    }
    return cardConfigs;
  }

}


