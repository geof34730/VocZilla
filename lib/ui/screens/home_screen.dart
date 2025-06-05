import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/data/repository/vocabulaire_repository.dart';
import 'package:vobzilla/ui/widget/home/CardHome.dart';
import 'package:vobzilla/ui/widget/home/HomeListTheme.dart';
import 'package:vobzilla/ui/widget/statistical/global_statisctical_widget.dart';
import '../../core/utils/ui.dart';
import '../../data/repository/vocabulaire_user_repository.dart';
import '../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';

import '../widget/statistical/LevelChart.dart';
import '../widget/home/CardClassementGamer.dart';
import '../widget/home/HomeListPerso.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  final bool listePerso = true;

  @override
  Widget build(BuildContext context) {
    return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                context.loc.home_title_progresse,
                style: TextStyle(
                    fontSize: 25,
                    fontFamily: GoogleFonts.titanOne().fontFamily)
            ),
            GlobalStatisticalWidget(
              isListPerso : false,
              isListTheme : false,
            ),
            HomelistPerso(),
            Text(
              context.loc.home_title_list_defined,
              style: TextStyle(
                fontSize: 25,
                fontFamily: GoogleFonts.titanOne().fontFamily)
            ),
            HorizontalScrollViewCardHome(
                children: [
                CardHome(
                  title: "TOP 20",
                  vocabulaireBegin: 0,
                  vocabulaireEnd: 20,
                  paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),

                ),
                CardHome(
                  title: "TOP 20 / 50",
                  vocabulaireBegin: 20,
                  vocabulaireEnd: 50,
                  paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                ),
                CardHome(
                  title: "TOP 50 / 100",
                  vocabulaireBegin: 50,
                  vocabulaireEnd: 100,
                  paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                  ),
                CardHome(
                  title: "TOP 100 / 200",
                  vocabulaireBegin: 100,
                  vocabulaireEnd: 200,
                  paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                ),
              ]
            ),
            Text(
                "Par themes",
                style: TextStyle(
                    fontSize: 25,
                    fontFamily: GoogleFonts.titanOne().fontFamily)
            ),
            HomelistThemes(),
            Text(
                context.loc.home_title_classement,
                style: TextStyle(
                    fontSize: 25,
                    fontFamily: GoogleFonts.titanOne().fontFamily)
            ),
            CardClassementGamer(position: 1),
            CardClassementGamer(position: 2),
            CardClassementGamer(position: 3),
          ]

    );
  }
}
