import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/logic/cubit/localization_cubit.dart';

import '../../../core/utils/detailTypeVocabulaire.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repository/vocabulaire_repository.dart';
import '../../widget/elements/PlaySoond.dart';

import '../../../core/utils/languageUtils.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';
import '../../widget/form/RadioChoiceVocabularyLearnedOrNot.dart';

class AllListsPersoScreen extends StatefulWidget {
  @override
  _AllListsPersoScreenState createState() => _AllListsPersoScreenState();
}

class _AllListsPersoScreenState extends State<AllListsPersoScreen> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabulairesBloc, VocabulairesState>(
      builder: (context, state) {
        if (state is VocabulairesLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is VocabulairesLoaded) {
            return Text("Perso");
        } else if (state is VocabulairesError) {
          return Center(child: Text(context.loc.error_loading));
        } else {
          return Center(child: Text(context.loc.unknown_error)); // fallback
        }
      },
    );
  }
}




