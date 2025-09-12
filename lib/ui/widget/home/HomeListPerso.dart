import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voczilla/core/utils/localization.dart';

import '../../../core/utils/logger.dart';
import '../../../core/utils/ui.dart';
import '../../../data/models/vocabulary_user.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';
import '../../../logic/cubit/localization_cubit.dart';
import 'CarHomeListPerso.dart';
import 'CardHome.dart';
import 'TitleWidget.dart';


class HomelistPerso extends StatelessWidget {
  final String view;
  final bool allListView;

  const HomelistPerso({
    super.key,
    required this.view,
    this.allListView = false,
  });

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
             final bool hasAnyPersoLists = data.listPerso.isNotEmpty;

             final List<Widget> persoWidgets = getListPerso(
                 context: context,
                 data: data,
                 view: view,
                 allListView: allListView,
                 withCarhome: 340);

             final bool hasVisibleLists = persoWidgets.isNotEmpty;

              return Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       titleWidget(text: context.loc.home_title_my_list_perso,codelang: Localizations.localeOf(context).languageCode),
                      if (hasAnyPersoLists)
                        Padding(
                          padding: EdgeInsets.only(left: 5,top:8),
                          // Remplacer ElevatedButton par un Material + IconButton pour un contrôle total de la taille
                          child: Material(
                            key: ValueKey('button_create_list'),
                            color: Colors.blue,
                            shape: CircleBorder(),
                            elevation: 5,
                            child: SizedBox(
                              width: 28, // Taille souhaitée pour le bouton
                              height: 28,
                              child: IconButton(
                                padding: EdgeInsets.all(0),
                                iconSize: 14, // Taille de l'icône
                                icon: Icon(Icons.add, color: Colors.white),
                                onPressed: () => addNewListPerso(context: context),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height:4),
                  // Si aucune liste n'est visible (soit parce qu'il n'y en a pas, soit parce qu'elles sont toutes filtrées),
                  // on affiche le message d'accueil.
                  if(!hasVisibleLists)
                    Padding(
                      child: descriptionListPersoEmpty(context: context),
                      padding: EdgeInsets.only(top: 0),
                    ),
                  // Sinon, on affiche la liste horizontale des cartes.
                  if(hasVisibleLists)
                    HorizontalScrollViewCardHome(
                      itemWidth: itemWidthListPerso(context: context, nbList: 3),
                          children: persoWidgets,
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
