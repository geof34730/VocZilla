import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import 'package:voczilla/data/models/vocabulary_user.dart';
import 'package:voczilla/ui/widget/home/HomeClassement.dart';
import 'package:voczilla/ui/widget/home/HomeListTheme.dart';
import 'package:voczilla/ui/widget/statistical/global_statisctical_widget.dart';

import '../../core/utils/getFontForLanguage.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/ui.dart';
import '../../data/services/vocabulaires_server_service.dart';
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
  Widget build(BuildContext context) {
    final codelang = Localizations.localeOf(context).languageCode;


    return Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
    /*            ElevatedButton(
                  key: ValueKey('test_share'),
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, "/share/21020ca0-31f9-4fdc-9e5a-4894028fb5ee");

                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child:  Text(
                    "test share 21020ca0-31f9-4fdc-9e5a-4894028fb5ee",
                    style: getFontForLanguage(
                      codelang: codelang,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
*/



                GlobalStatisticalWidget(
                  isListPerso: false,
                  isListTheme: false,
                  local: codelang,
                  listName: null,
                  title: context.loc.home_title_progresse,
                ),
                const SizedBox(height: 8),
                BlocBuilder<VocabulaireUserBloc, VocabulaireUserState>(
                  builder: (context, state) {
                    if (state is VocabulaireUserLoaded) {
                       return HomelistPerso(
                        view: "home",
                        allListView: state.data.allListView,
                      );
                    }
                    // Si l'état est initial, on déclenche le chargement.
                    if (state is VocabulaireUserInitial) {
                      context.read<VocabulaireUserBloc>().add(CheckVocabulaireUserStatus(local: codelang));
                    }
                    // Pour tous les autres cas (Initial, Loading, Empty, Error), on affiche un loader.
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                titleWidget(text: context.loc.home_title_list_defined, codelang: codelang),
                BlocBuilder<VocabulaireUserBloc, VocabulaireUserState>(
                  builder: (context, state) {
                  if (state is VocabulaireUserLoaded) {
                      return HorizontalScrollViewCardHome(
                          children: getListDefined(
                              view: "home",
                              allListView: state.data.allListView,
                              listDefinedEnd: state.data.ListDefinedEnd.toSet(),
                              context: context,
                              withCarhome: 340
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
                BlocBuilder<VocabulaireUserBloc, VocabulaireUserState>(
                  builder: (context, state) {
                    if (state is VocabulaireUserLoaded) {
                          return HomelistThemes(
                            view: "home",
                            allListView: state.data.allListView,
                          );
                    }
                    // Si l'état est initial, on déclenche le chargement.
                    if (state is VocabulaireUserInitial) {
                      context.read<VocabulaireUserBloc>().add(CheckVocabulaireUserStatus(local: codelang));
                    }
                    // Pour tous les autres cas (Initial, Loading, Empty, Error), on affiche un loader.
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
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
