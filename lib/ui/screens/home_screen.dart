import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/logic/blocs/user/user_bloc.dart';
import 'package:voczilla/logic/blocs/user/user_event.dart';
import 'package:voczilla/logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import 'package:voczilla/data/models/vocabulary_user.dart';
import 'package:voczilla/ui/widget/home/HomeClassement.dart';
import 'package:voczilla/ui/widget/home/HomeListTheme.dart';
import 'package:voczilla/ui/widget/statistical/global_statisctical_widget.dart';

import '../../core/utils/getFontForLanguage.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/ui.dart';
import '../../data/repository/vocabulaire_user_repository.dart';
import '../../global.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../widget/form/swichListFinished.dart';
import '../widget/home/CarHomeListDefinied.dart';
import '../widget/home/TitleWidget.dart';
import '../widget/home/HomeListPerso.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Logger.Green.log("***********************addPostFrameCallback** importListPersoFromSharePref ********************************************");
      final bool wasImported = await VocabulaireUserRepository().importListPersoFromSharePref();

      if (mounted) {
        final codelang = Localizations.localeOf(context).languageCode;
        if (wasImported) {
          Logger.Green.log("Nouvelle liste importée, déclenchement de la mise à jour de l'UI.");
          context.read<VocabulaireUserBloc>().add(VocabulaireUserRefresh(local: codelang));

          Logger.Green.log("Déclenchement de la mise à jour globale en arrière-plan.");
          context.read<UserBloc>().add(InitializeUserSession());
        } else {
          Logger.Green.log("Aucune nouvelle liste, chargement des données locales.");
          context.read<VocabulaireUserBloc>().add(CheckVocabulaireUserStatus(local: codelang));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final codelang = Localizations.localeOf(context).languageCode;
    Logger.Green.log("BUILD HomeScreen");
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*ElevatedButton(
                key: ValueKey('test_share'),
                onPressed: (){
                  Navigator.pushReplacementNamed(context, "/share/5834bc7f-bacb-4493-9787-5744c26ec0df");
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child:  Text(
                  "test share 5834bc7f-bacb-4493-9787-5744c26ec0df",
                  style: getFontForLanguage(
                    codelang: codelang,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),*/
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
                  if (state is VocabulaireUserInitial) {
                    context.read<VocabulaireUserBloc>().add(CheckVocabulaireUserStatus(local: codelang));
                  }
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
                        withCarhome: 340,
                      ),
                    );
                  }
                  if (state is VocabulaireUserInitial) {
                    context.read<VocabulaireUserBloc>().add(CheckVocabulaireUserStatus(local: codelang));
                  }
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
                  if (state is VocabulaireUserInitial) {
                    context.read<VocabulaireUserBloc>().add(CheckVocabulaireUserStatus(local: codelang));
                  }
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
            child: Center(child: SwitchListFinished()),
          ),
        ),
      ],
    );
  }
}
