import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';

import '../../../core/utils/logger.dart';
import '../../../core/utils/ui.dart';
import '../../../data/models/vocabulary_user.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';
import '../../../logic/cubit/localization_cubit.dart';
import 'CardHome.dart';
import 'TitleWidget.dart';


class HomelistPerso extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<VocabulaireUserBloc, VocabulaireUserState>(
        builder: (context, state) {
          if (state is VocabulaireUserLoading) {
            return Center(child: CircularProgressIndicator());
          } else if( state is VocabulaireUserUpdate){
            return Center(child: CircularProgressIndicator());
          } else if (state is VocabulaireUserLoaded  ) {
            int i =0;
             final VocabulaireUser data = state.data;
             final bool listePerso = data.listPerso.length>0;
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: titleWidget(text: context.loc.home_title_my_list_perso,codelang: Localizations.localeOf(context).languageCode),
                      ),
                      if (listePerso)
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: ElevatedButton(
                            key: ValueKey('button_create_list'),
                            onPressed: () {
                              addNewListPerso(context: context);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              elevation: 2,
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.all(0),
                            ),
                            child: Icon(Icons.add, size: 25, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  if(!listePerso)
                    descriptionListPersoEmpty(context: context),

                  if(listePerso)
                    HorizontalScrollViewCardHome(
                      itemWidth: itemWidthListPerso(context: context, nbList: 3),
                          children: data.listPerso.reversed.map((listPerso) {
                            i=i+1;
                            print(i.toString());
                            return CardHome(
                              keyStringTest: i.toString(),
                              nbVocabulaire:listPerso.listGuidVocabulary.length,
                              guid: listPerso.guid,
                              title: listPerso.title,
                              backgroundColor: Color(listPerso.color), // Remplacez par la couleur appropriée
                              editMode: listPerso.ownListShare,
                              isListShare:listPerso.isListShare,
                              ownListShare: listPerso.ownListShare,
                              list: listPerso,
                              isListPerso:true,
                              paddingLevelBar: EdgeInsets.only(top: 5),
                            );
                          }).toList()
                    ),
                ],
              );
            } else if (state is VocabulaireUserError) {
              return Center(child: Text(context.loc.error_loading));
            } else {
              if(state is VocabulaireUserEmpty) {
                return Column(
                  children: [
                    titleWidget(text: context.loc.home_title_my_list_perso,codelang: Localizations.localeOf(context).languageCode),
                    descriptionListPersoEmpty(context: context),
                  ],
                );
              }
              else{
                return Center(child: Text(context.loc.unknown_error)); // fallback
              }
            }
        }
    );
  }

  addNewListPerso({required BuildContext context}) {
    Navigator.pushNamed(context, "/personnalisation/step1");
  }

  Card descriptionListPersoEmpty({required BuildContext context}){
    return Card(
      color: Colors.blueGrey,
      child: ListTile(
          title: Padding(
            padding: EdgeInsets.only(top: 10, left: 5, right: 5),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    context.loc.home_description_list_perso,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        height: 1.2,
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.roboto().fontFamily
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      key: ValueKey('buttonAddList'),
                      onPressed: () {
                        addNewListPerso(context: context);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        elevation: 2,
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.all(0),
                      ),
                      child: Icon(Icons.add, size: 30,color: Colors.white), // Utiliser une icône ou un texte court
                    ),
                  ),
                ]
            ),
          )
      ),
    );
  }

}

