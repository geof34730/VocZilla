import 'package:flutter/material.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/ui/widget/home/CardHome.dart';
import 'dart:math';

import '../../../app_route.dart';
import '../../../global.dart';


List<Widget> getListDefined({
  required BuildContext context,
  required String view,
  required bool allListView,
  required Set<String> listDefinedEnd,
}) {
  final double withCarhome = 340;
  final List<Map<String, int>> cardConfigs = [
    {'begin': 0, 'end': 20},
    {'begin': 20, 'end': 50},
    {'begin': 50, 'end': 100},
    {'begin': 100, 'end': 200},
    {'begin': 200, 'end': 300},
    {'begin': 300, 'end': 400},
  ];


  // Toujours générer la liste complète des configurations possibles.
  for (int i = 400; i < globalCountVocabulaireAll; i += 100) {
    final int endValue = min(i + 200, globalCountVocabulaireAll);
    cardConfigs.add({'begin': i, 'end': endValue});
  }

  // 1. Transformer toutes les configurations en données de carte.
  final allCards = cardConfigs.map((config) {
      final int begin = config['begin']!;
      final int end = config['end']!;
      String title;
      String keyStringTest;

      if (begin == 0) {
        title = "TOP $end";
        keyStringTest = "top$end";
      } else {
        title = "TOP $begin / $end";
        keyStringTest = "top$begin$end";
      }

      return {
        'title': title,
        'keyStringTest': keyStringTest,
        'begin': begin,
        'end': end
      };
    }).toList();

  // 2. Appliquer la logique de filtrage et de sélection en fonction de la vue.
  List<Map<String, dynamic>> cardsToDisplay;

  if (view == "home") {
    if (allListView) {
      // Vue "home" avec filtre : afficher les 6 prochaines listes non terminées.
      cardsToDisplay = allCards
          .where((card) => !listDefinedEnd.contains(card['keyStringTest']))
          .take(6)
          .toList();
    } else {
      // Vue "home" par défaut : afficher les 6 premières listes, peu importe leur état.
      cardsToDisplay = allCards.take(6).toList();
    }
  } else {
    // Autres vues (ex: page de toutes les listes)
    cardsToDisplay = allListView
        ? allCards.where((card) => !listDefinedEnd.contains(card['keyStringTest'])).toList()
        : allCards;
  }

  // 3. Construire les widgets à partir des données de carte sélectionnées.
  List<Widget> widgets = cardsToDisplay.map((cardData) {
      return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SizedBox(
            width: withCarhome,
            child: CardHome(
              title: cardData['title'] as String,
              keyStringTest: cardData['keyStringTest'] as String,
              listName: cardData['keyStringTest'] as String,
              vocabulaireBegin: cardData['begin'] as int,
              vocabulaireEnd: cardData['end'] as int,
              paddingLevelBar: const EdgeInsets.only(
                  bottom: 10, top: 5),
            ),
          ),
      );
    }).toList();

  // 4. Ajouter la carte "+ de listes" si on est sur la vue "home"
  if (view == "home") {
    widgets.add(
      Padding(
        padding: const EdgeInsets.only(top: 4, left: 0, right: 4),
          child: SizedBox(

            height: 125,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoute.allListsDefined);
              },
              child: Card(
                color: Colors.green,
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.remove_red_eye_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Voir toutes les listes",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18,color: Colors.white),
                    ),
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
