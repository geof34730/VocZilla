import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/logic/cubit/localization_cubit.dart';

import '../../../core/utils/detailTypeVocabulaire.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/vocabulary_user.dart';
import '../../../data/repository/vocabulaire_repository.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../../widget/elements/PlaySoond.dart';

import '../../../core/utils/languageUtils.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';
import '../../widget/form/RadioChoiceVocabularyLearnedOrNot.dart';
import '../../widget/form/swichListFinished.dart';
import '../../widget/home/CarHomeListDefinied.dart';
import '../../widget/home/CardHome.dart';
import '../../widget/statistical/global_statisctical_widget.dart';

class AllListsDefinedScreen extends StatefulWidget {
  @override
  _AllListsDefinedScreenState createState() => _AllListsDefinedScreenState();
}

class _AllListsDefinedScreenState extends State<AllListsDefinedScreen> {

  @override
  Widget build(BuildContext context) {
    final codelang = Localizations.localeOf(context).languageCode;
        return BlocBuilder<VocabulaireUserBloc, VocabulaireUserState>(
            builder: (context, state) {
              if (state is VocabulaireUserLoading) {
                return Center(child: CircularProgressIndicator());
              } else if( state is VocabulaireUserUpdate){
                return Center(child: CircularProgressIndicator());
              } else if (state is VocabulaireUserLoaded  ) {
                return Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          GlobalStatisticalWidget(
                            isListPerso: false,
                            isListTheme: false,
                            local: codelang,
                            listName: null,
                            title: context.loc.title_all_list_defined,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top:30,bottom: 20),
                            child: Wrap(
                                spacing: 8.0, // Espace horizontal entre les cartes
                                runSpacing: 8.0, // Espace vertical entre les lignes
                                alignment: WrapAlignment.center,
                                children: getListDefined(
                                  view: "allList",
                                  allListView: state.data.allListView,
                                  listDefinedEnd: state.data.ListDefinedEnd.toSet(),
                                  context:context,
                                  withCarhome: 360
                                ))
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top:70,
                      left: 0,
                      right: 0,
                      child: Material(
                        color: Colors.transparent,
                        child: Center(child: SwitchListFinished()),
                      ),
                    ),
                  ],
                );
              } else if (state is VocabulaireUserError) {
                  return Center(child: Text(context.loc.error_loading));
              } else {
                  return Center(child: Text(context.loc.unknown_error)); // fallback
              }
            }
        );
  }
}
