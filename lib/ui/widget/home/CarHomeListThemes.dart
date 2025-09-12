import 'package:flutter/material.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/ui/widget/home/CardHome.dart';

import '../../../app_route.dart';
import '../../../core/utils/languageUtils.dart';
import '../../../data/models/vocabulary_user.dart';

/// Génère la liste de widgets pour les cartes de thèmes.
List<Widget> getListThemes({
  required BuildContext context,
  required VocabulaireUser data,
  required String view,
  required bool allListView,
  required double withCarhome,
}) {
  final allThemes = data.listTheme;
  final listDefinedEnd = data.ListDefinedEnd; // On utilise la source de vérité depuis l'objet data



  // 1. Filtrer les thèmes à afficher en fonction de la vue et du filtre
  List<ListTheme> themesToDisplay;
  if (view == "home") {
    // Pour la vue "home", on filtre d'abord, puis on limite à 6



    List<ListTheme> filteredThemes = allListView
        ? allThemes.where((theme) => !listDefinedEnd.contains(theme.guid)).toList()
        : allThemes;
    themesToDisplay = filteredThemes.take(6).toList();
  } else {
    // Pour les autres vues, on applique juste le filtre sans limiter le nombre
    themesToDisplay = allListView
        ? allThemes.where((theme) => !listDefinedEnd.contains(theme.guid)).toList()
        : allThemes;
  }

  // 2. Construire la liste des widgets CardHome
  List<Widget> themeWidgets = themesToDisplay.map((listTheme) {
    return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: SizedBox(
            width: withCarhome,
            child:  CardHome(
          keyStringTest: listTheme.guid,
          listName: listTheme.guid,
          isListTheme: true,
          nbVocabulaire: listTheme.listGuidVocabulary.length,
          guid: listTheme.guid,
          title: listTheme.title[LanguageUtils.getSmallCodeLanguage(context: context).toLowerCase()] ?? "Default Title",
          backgroundColor: Colors.greenAccent,
          list: listTheme,
          paddingLevelBar: const EdgeInsets.only(top: 5),
        )));
  }).toList();

  // 3. Ajouter la carte "Voir plus" si on est sur la page d'accueil
  if (view == "home") {
    themeWidgets.add(
      Padding(
        padding: const EdgeInsets.only(top: 4, left: 0, right: 4),
        child: SizedBox(
          height: 125,
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoute.allListsThemes);
            },
            child: Card(
              color: Colors.green,
              elevation: 5.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.remove_red_eye_rounded, size: 50, color: Colors.white),
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

  return themeWidgets;
}
