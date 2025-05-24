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


class HomelistPerso extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabulaireUserBloc, VocabulaireUserState>(
        builder: (context, state) {
          if (state is VocabulaireUserLoading) {
            return Center(child: CircularProgressIndicator());
          } else if( state is VocabulaireUserUpdate){
            return Center(child: CircularProgressIndicator());
          } else if (state is VocabulaireUserLoaded ) {
             final VocabulaireUser data = state.data;
             final bool listePerso = data.listPerso.length>0;
              return Column(
                children: [
                  Row(
                    children: [
                      Text(
                          context.loc.home_title_my_list_perso,
                          style: TextStyle(
                              fontSize: 25,
                              fontFamily: GoogleFonts
                                  .titanOne()
                                  .fontFamily
                          )
                      ),
                      if(listePerso)
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: ElevatedButton(
                            onPressed: () {
                              addNewListPerso(context: context);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              elevation: 2,
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.all(0),
                            ),
                            child: Icon(Icons.add, size: 25, color: Colors.white), // Utiliser une icône ou un texte court
                          ),
                        )
                    ],
                  ),
                  if(!listePerso)
                    Card(
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
                                        fontFamily: GoogleFonts
                                            .roboto()
                                            .fontFamily
                                    ),
                                  ),
                                  Center(
                                    child: ElevatedButton(
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
                    ),

                  if(listePerso)
                    HorizontalScrollViewCardHome(
                      itemWidth: itemWidthListPerso(
                          context: context, nbList: 3),
                          children: data.listPerso.reversed.map((listPerso) {
                            return CardHome(

                              nbVocabulaire:listPerso.listGuidVocabulary.length,
                              guid: listPerso.guid,
                              title: listPerso.title,
                              backgroundColor: Color(listPerso.color), // Remplacez par la couleur appropriée
                              editMode: listPerso.ownListShare,
                              isListShare:listPerso.isListShare,
                              ownListShare: listPerso.ownListShare,
                              listPerso: listPerso,
                              isListPero:true,
                              paddingLevelBar: EdgeInsets.only(top: 5),
                            );
                          }).toList()

                    ),
                ],
              );
            } else if (state is VocabulairesError) {
              return Center(child: Text(context.loc.error_loading));
            } else {
              return Center(child: Text(context.loc.unknown_error)); // fallback
            }
        }
    );
  }

  addNewListPerso({required BuildContext context}) {
    Navigator.pushNamed(context, "/personnalisation/step1");
  }

}

