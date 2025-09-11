import 'package:flutter/material.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/ui/widget/home/HomeClassement.dart';
import 'package:voczilla/ui/widget/home/HomeListTheme.dart';
import 'package:voczilla/ui/widget/statistical/global_statisctical_widget.dart';

import '../../core/utils/ui.dart';
import '../widget/form/swichListFinished.dart';
import '../widget/home/CarHomeListDefinied.dart';
import '../widget/home/TitleWidget.dart';
import '../widget/home/HomeListPerso.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final codelang = Localizations.localeOf(context).languageCode;

    return Stack(
        children: [
          // --- CONTENU DE LA PAGE (scrollable) ---
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlobalStatisticalWidget(
                  isListPerso: false,
                  isListTheme: false,
                  local: codelang,
                  listName: null,
                  title: context.loc.home_title_progresse,
                ),
                const SizedBox(height: 8),
                HomelistPerso(),
                titleWidget(text: context.loc.home_title_list_defined, codelang: codelang),
                HorizontalScrollViewCardHome(children: getListDefined(view: "home")),
                titleWidget(text: context.loc.by_themes, codelang: codelang),
                HomelistThemes(),
                titleWidget(text: context.loc.home_title_classement, codelang: codelang),
                const HomeClassement(),
              ],
            ),
          ),

          // --- SWITCH ÉPINGLÉ EN HAUT-DROITE ---
          Positioned(
            right: -10,      // <- ajuste pour le placer où tu veux
            top: 62,        // <- idem
            child: Material( // assure un hit-test propre dans l’overlay
              color: Colors.transparent,
              child: SwitchListFinished(),
            ),
          ),
        ],

    );
  }

}
