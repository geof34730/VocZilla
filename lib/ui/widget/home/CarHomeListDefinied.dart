import 'package:flutter/material.dart';
import 'package:voczilla/data/repository/vocabulaire_user_repository.dart';
import 'package:voczilla/ui/widget/home/CardHome.dart';
import 'dart:math';

import '../../../global.dart';

List<Widget> getListDefined({required String view}) {
  final double withCarhome = 340;





  final List<Map<String, int>> cardConfigs = [
    {'begin': 0, 'end': 20},
    {'begin': 20, 'end': 50},
    {'begin': 50, 'end': 100},
    {'begin': 100, 'end': 200},
    {'begin': 200, 'end': 300},
    {'begin': 300, 'end': 400},
  ];
  if(view!="home") {
    for (int i = 400; i < globalCountVocabulaireAll; i += 100) {
      final int endValue = min(i + 200, globalCountVocabulaireAll);
      cardConfigs.add({'begin': i, 'end': endValue});
    }
  }
  return cardConfigs.map((config) {
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

    return SizedBox(
      width: withCarhome,
      child: CardHome(
        title: title,
        keyStringTest: keyStringTest,
        listName: keyStringTest,
        vocabulaireBegin: begin,
        vocabulaireEnd: end,
        paddingLevelBar: const EdgeInsets.only(bottom: 10, top: 5),
      ),
    );
  }).toList();
}
