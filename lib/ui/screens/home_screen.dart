import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/data/repository/vocabulaire_repository.dart';
import 'package:voczilla/ui/widget/home/CardHome.dart';
import 'package:voczilla/ui/widget/home/HomeClassement.dart';
import 'package:voczilla/ui/widget/home/HomeListTheme.dart';
import 'package:voczilla/ui/widget/statistical/global_statisctical_widget.dart';
import '../../core/utils/getFontForLanguage.dart';
import '../../core/utils/languageUtils.dart';
import '../../core/utils/ui.dart';
import '../../data/repository/data_user_repository.dart';
import '../../data/repository/vocabulaire_user_repository.dart';
import '../../logic/blocs/notification/notification_bloc.dart';
import '../../logic/blocs/notification/notification_event.dart';
import '../../logic/blocs/user/user_bloc.dart';
import '../../logic/blocs/user/user_event.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';

import '../widget/home/CarHomeListDefinied.dart';
import '../widget/home/TitleWidget.dart';
import '../widget/home/CardClassementGamer.dart';
import '../widget/home/HomeListPerso.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  final bool listePerso = true;

  @override
  Widget build(BuildContext context) {
    final codelang = Localizations.localeOf(context).languageCode;
    bool light = false;
    return Column(
          key: ValueKey('home_logged'),
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlobalStatisticalWidget(
              isListPerso : false,
              isListTheme : false,
              local: codelang,
              listName: null,
              title: context.loc.home_title_progresse,
            ),
            Center(
              child:Switch(
                value: light,
                onChanged: (bool value) {
                    light = value;
                },
              )
            ),
            HomelistPerso(),
            titleWidget(text: context.loc.home_title_list_defined,codelang: codelang),
            HorizontalScrollViewCardHome(
                children: getListDefined(view:"home")
            ),
            titleWidget(text: context.loc.by_themes,codelang: codelang),
            HomelistThemes(),
            titleWidget(text: context.loc.home_title_classement,codelang: codelang),
            HomeClassement()
          ]
    );
  }
}
