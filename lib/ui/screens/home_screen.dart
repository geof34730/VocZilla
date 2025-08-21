import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/data/repository/vocabulaire_repository.dart';
import 'package:vobzilla/ui/widget/home/CardHome.dart';
import 'package:vobzilla/ui/widget/home/HomeClassement.dart';
import 'package:vobzilla/ui/widget/home/HomeListTheme.dart';
import 'package:vobzilla/ui/widget/statistical/global_statisctical_widget.dart';
import '../../core/utils/getFontForLanguage.dart';
import '../../core/utils/ui.dart';
import '../../data/repository/data_user_repository.dart';
import '../../data/repository/vocabulaire_user_repository.dart';
import '../../logic/blocs/notification/notification_bloc.dart';
import '../../logic/blocs/notification/notification_event.dart';
import '../../logic/blocs/user/user_bloc.dart';
import '../../logic/blocs/user/user_event.dart';
import '../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';

import '../widget/home/TitleWidget.dart';
import '../widget/home/CardClassementGamer.dart';
import '../widget/home/HomeListPerso.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  final bool listePerso = true;

  @override
  Widget build(BuildContext context) {
    final codelang = Localizations.localeOf(context).languageCode;
    return Column(
          key: ValueKey('home_logged'),
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleWidget(text:  context.loc.home_title_progresse,codelang: codelang),
            GlobalStatisticalWidget(
              isListPerso : false,
              isListTheme : false,
            ),



            HomelistPerso(),
            titleWidget(text: context.loc.home_title_list_defined,codelang: codelang),
            HorizontalScrollViewCardHome(
                children: [
                CardHome(
                  title: "TOP 20",
                  keyStringTest: "top20",
                  vocabulaireBegin: 0,
                  vocabulaireEnd: 20,
                  paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                ),
                CardHome(
                  title: "TOP 20 / 50",
                  keyStringTest: "top2050",
                  vocabulaireBegin: 20,
                  vocabulaireEnd: 50,
                  paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                ),
                CardHome(
                  title: "TOP 50 / 100",
                  keyStringTest: "top50100",
                  vocabulaireBegin: 50,
                  vocabulaireEnd: 100,
                  paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                  ),
                CardHome(
                  title: "TOP 100 / 200",
                  keyStringTest: "top100200",
                  vocabulaireBegin: 100,
                  vocabulaireEnd: 200,
                  paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                ),
                  CardHome(
                    title: "TOP 200 / 500",
                    keyStringTest: "top100200",
                    vocabulaireBegin: 200,
                    vocabulaireEnd: 500,
                    paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                  ),
              ]
            ),
            titleWidget(text: context.loc.by_themes,codelang: codelang),
            HomelistThemes(),
            titleWidget(text: context.loc.home_title_classement,codelang: codelang),
            HomeClassement()
          ]

    );
  }
}
