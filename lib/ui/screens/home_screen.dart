import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import 'package:voczilla/data/models/vocabulary_user.dart';
import 'package:voczilla/ui/widget/home/HomeClassement.dart';
import 'package:voczilla/ui/widget/home/HomeListTheme.dart';
import 'package:voczilla/ui/widget/statistical/global_statisctical_widget.dart';

import '../../core/utils/ui.dart';
import '../../global.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
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
                BlocBuilder<VocabulaireUserBloc, VocabulaireUserState>(
                  builder: (context, state) {

                    if (state is VocabulaireUserLoaded) {
                      print("****************************************************");
                      print(state.data.allListView);
                      print(state.data.ListDefinedEnd.toSet());
                      print("****************************************************");
                      return HorizontalScrollViewCardHome(
                          children: getListDefined(
                              view: "home",
                              allListView: state.data.allListView,
                              listDefinedEnd: state.data.ListDefinedEnd.toSet(),
                              context: context,
                          ));
                    }
                    // Si l'état est initial, on déclenche le chargement.
                    if (state is VocabulaireUserInitial) {
                      context.read<VocabulaireUserBloc>().add(CheckVocabulaireUserStatus(local: codelang));
                    }
                    // Pour tous les autres cas (Initial, Loading, Empty, Error), on affiche un loader.
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                titleWidget(text: context.loc.by_themes, codelang: codelang),
                HomelistThemes(),
                titleWidget(text: context.loc.home_title_classement, codelang: codelang),
                const HomeClassement(),
              ],
            ),
          ),
          Positioned(
            top: 64,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Center(child:SwitchListFinished()),
            ),
          ),
        ],
    );
  }
}
