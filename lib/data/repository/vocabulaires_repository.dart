import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/logger.dart';
import '../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../logic/blocs/vocabulaires/vocabulaires_event.dart';
import '../../ui/screens/vocabulary/list_screen.dart';
import '../services/vocabulaires_service.dart';

class VocabulairesRepository {
  final BuildContext context;
  VocabulairesRepository({required this.context});

  final VocabulaireService _vocabulaireService = VocabulaireService();
   goVocabulairesTop({required int vocabulaireBegin, required int vocabulaireEnd, required String titleList}) async {
    Logger.Pink.log("goVocabulaires DATA");
    var data =  await getDataTop();
    // Tu crées le bloc
    final List<dynamic> dataSlice = data.sublist(vocabulaireBegin, vocabulaireEnd);
    var dataSliceWithTitle = {
        "title": titleList,
        "vocabulaireList": dataSlice,
      };
    final bloc = VocabulairesBloc();
    // Tu lui passes les data déjà chargées
    Logger.Pink.log(dataSliceWithTitle);
    context.read<VocabulairesBloc>().add(LoadVocabulairesData(dataSliceWithTitle));
  }


  goVocabulairesThemes() {}

  goVocabulairesPerso() {}

  Future<List<dynamic>> getDataTop(){
    var dataAll=_vocabulaireService.getAllData();
    return dataAll;
  }



}


