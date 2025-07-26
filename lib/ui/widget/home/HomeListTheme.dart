import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';

import '../../../core/utils/languageUtils.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/ui.dart';
import '../../../data/models/vocabulary_user.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';
import '../../../logic/cubit/localization_cubit.dart';
import 'CardHome.dart';


class HomelistThemes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabulaireUserBloc, VocabulaireUserState>(
        builder: (context, state) {
          if (state is VocabulaireUserLoading) {
            return Center(child: CircularProgressIndicator());
          } else if( state is VocabulaireUserUpdate){
            return Center(child: CircularProgressIndicator());
          } else if (state is VocabulaireUserLoaded  ) {
             final VocabulaireUser data = state.data;
             //final bool listePerso = data.listTheme.length>0;
              return Column(
                children: [
                  HorizontalScrollViewCardHome(
                      itemWidth: itemWidthListPerso(context: context, nbList: 3),
                      children: data.listTheme.map((listTheme) {
                        return CardHome(
                          keyStringTest: listTheme.guid,
                          isListTheme: true,
                          nbVocabulaire:listTheme.listGuidVocabulary.length,
                          guid: listTheme.guid,
                          title: listTheme.title[LanguageUtils.getSmallCodeLanguage(context: context).toLowerCase()] ?? "Default Title",
                          backgroundColor: Colors.greenAccent, // Remplacez par la couleur appropriée
                          list: listTheme,
                          //isListTheme:true,
                          paddingLevelBar: EdgeInsets.only(top: 5),
                        );
                      }).toList()
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

