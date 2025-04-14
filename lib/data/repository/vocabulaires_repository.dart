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
  goVocabulairesTop({required int vocabulaireBegin, required int vocabulaireEnd}) async {
    Logger.Pink.log("goVocabulaires");
    var data =  await getDataTop();
    // Tu crées le bloc

    final List<dynamic> dataSlice = data.sublist(0, 20);

    final bloc = VocabulairesBloc();
    // Tu lui passes les data déjà chargées
    Logger.Pink.log(dataSlice);



    context.read<VocabulairesBloc>().add(LoadVocabulairesData(dataSlice));
  }

  goVocabulairesThemes() {}

  goVocabulairesPerso() {}

  Future<List<dynamic>> getDataTop(){
    var dataAll=_vocabulaireService.getAllData();
    return dataAll;
  }



}


