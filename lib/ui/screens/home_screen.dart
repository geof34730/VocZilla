import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/data/repository/vocabulaire_repository.dart';
import 'package:vobzilla/ui/widget/home/CardHome.dart';
import 'package:vobzilla/ui/widget/statistical/global_statisctical_widget.dart';
import '../../core/utils/ui.dart';
import '../../data/repository/vocabulaire_user_repository.dart';
import '../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';

import '../widget/elements/LevelChart.dart';
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
                "Ma progression de titan",
                style: TextStyle(
                    fontSize: 25,
                    fontFamily: GoogleFonts.titanOne().fontFamily)
            ),
          GlobalStatisticalWidget(),


            HomelistPerso(),
            Text(
              "De Petit Monstre à Titan",
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
                "Classement TeamZilla",
                style: TextStyle(
                    fontSize: 25,
                    fontFamily: GoogleFonts.titanOne().fontFamily)
            ),

            CardClassementGamer(position: 1),
            CardClassementGamer(position: 2),
            CardClassementGamer(position: 3),
            /*
            Text(
                "Par themes",
                style: TextStyle(
                    fontSize: 25,
                    fontFamily: GoogleFonts.titanOne().fontFamily)
            ),
            HorizontalScrollViewCardHome(
                children: [
                  CardHome(
                    title: "Sport",
                    vocabulaireBegin: 0,
                    vocabulaireEnd: 20,
                    paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                  ),
                  CardHome(
                    title: "Voyage",
                    vocabulaireBegin: 0,
                    vocabulaireEnd: 19,
                    paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                  ),
                  CardHome(
                    title: "Business",
                    vocabulaireBegin: 0,
                    vocabulaireEnd: 19,
                    paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                  ),
                  CardHome(
                    title: "Cuisine",
                    vocabulaireBegin: 0,
                    vocabulaireEnd: 19,
                    paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                  ),
                  CardHome(
                    title: "Culture",
                    vocabulaireBegin: 0,
                    vocabulaireEnd: 19,
                    paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                  ),
                ]
            ),


            */

          ]

    );
  }
}
