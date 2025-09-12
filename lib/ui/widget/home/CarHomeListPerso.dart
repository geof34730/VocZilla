import 'package:flutter/material.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/data/models/vocabulary_user.dart';

import '../../../app_route.dart';
import 'CardHome.dart';

/// Génère la liste de widgets pour les cartes des listes personnelles.
List<Widget> getListPerso({
  required BuildContext context,
  required VocabulaireUser data,
  required String view,
  required bool allListView,
  required double withCarhome,
}) {
  final allPersoLists = data.listPerso.reversed.toList();
  final listDefinedEnd = data.ListDefinedEnd;

  // 1. Filtrer les listes à afficher en fonction de la vue et du filtre
  List<ListPerso> listsToDisplay;
  if (view == "home") {
    // Pour la vue "home", on filtre d'abord, puis on limite à 6
    List<ListPerso> filteredLists = allListView
        ? allPersoLists.where((list) => !listDefinedEnd.contains(list.guid)).toList()
        : allPersoLists;
    listsToDisplay = filteredLists.take(6).toList();
  } else {
    // Pour les autres vues, on applique juste le filtre sans limiter le nombre
    listsToDisplay = allListView
        ? allPersoLists.where((list) => !listDefinedEnd.contains(list.guid)).toList()
        : allPersoLists;
  }

  List<Widget> widgets = listsToDisplay.map((listPerso) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: SizedBox(
        width: withCarhome,
        child: CardHome(
          keyStringTest: listPerso.guid,
          listName: listPerso.guid,
          nbVocabulaire: listPerso.listGuidVocabulary.length,
          guid: listPerso.guid,
          title: listPerso.title,
          backgroundColor: Color(listPerso.color),
          editMode: listPerso.ownListShare,
          isListShare: listPerso.isListShare,
          ownListShare: listPerso.ownListShare,
          list: listPerso,
          isListPerso: true,
          paddingLevelBar: EdgeInsets.only(top: 5),
          isListEnd: listDefinedEnd.contains(listPerso.guid),
        ),
      ),
    );
  }).toList();

  // Ajouter la carte "Voir toutes les listes" si on est sur la vue "home"
  if (view == "home" && listsToDisplay.isNotEmpty) {
    widgets.add(
      Padding(
        padding: const EdgeInsets.only(top: 4, left: 0, right: 4),
        child: SizedBox(
          height: 155,
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoute.allListsPerso);
            },
            child: Card(
              color: Colors.blue, // Couleur pour les listes perso
              elevation: 5.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_red_eye_rounded, size: 50, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(context.loc.view_all_list, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  return widgets;
}
