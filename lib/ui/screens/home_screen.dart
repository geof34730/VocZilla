import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/logic/blocs/user/user_bloc.dart';
import 'package:voczilla/logic/blocs/user/user_event.dart';
import 'package:voczilla/logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import 'package:voczilla/services/admob_service.dart';
import 'package:voczilla/ui/widget/ads/banner_ad_widget.dart';
import 'package:voczilla/ui/widget/home/HomeClassement.dart';
import 'package:voczilla/ui/widget/home/HomeListTheme.dart';
import 'package:voczilla/ui/widget/statistical/global_statisctical_widget.dart';

import '../../core/utils/logger.dart';
import '../../core/utils/ui.dart';
import '../../data/repository/vocabulaire_user_repository.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart'
    hide VocabulaireUserUpdate;
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
      Logger.Green.log(
          "***********************addPostFrameCallback** importListPersoFromSharePref ********************************************");
      final bool wasImported =          await VocabulaireUserRepository().importListPersoFromSharePref();

      if (mounted) {
        final codelang = Localizations.localeOf(context).languageCode;
        if (wasImported) {
          Logger.Green.log("Nouvelle liste importée, déclenchement de la mise à jour de l'UI.");
          context
              .read<VocabulaireUserBloc>()
              .add(VocabulaireUserRefresh(local: codelang));

          Logger.Green.log("Déclenchement de la mise à jour globale en arrière-plan.");
          context.read<UserBloc>().add(InitializeUserSession());
        } else {
          Logger.Green.log("Aucune nouvelle liste, chargement des données locales.");
          context
              .read<VocabulaireUserBloc>()
              .add(CheckVocabulaireUserStatus(local: codelang));
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
              GlobalStatisticalWidget(
                isListPerso: false,
                isListTheme: false,
                local: codelang,
                listName: null,
                title: context.loc.home_title_progresse,
              ),
              const SizedBox(height: 8),
              AdaptiveBannerAdWidget(
                  key: ValueKey('home_top_banner'),
                  padding:EdgeInsets.only(top:8)
              ),
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

              const SizedBox(height: 8),
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
              //AdaptiveBannerAdWidget(padding:EdgeInsets.only(top:8)),// Une autre bannière adaptative
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
                    context
                        .read<VocabulaireUserBloc>()
                        .add(CheckVocabulaireUserStatus(local: codelang));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              AdaptiveBannerAdWidget(
                  key: ValueKey('home_bottom_banner'),
                  padding:EdgeInsets.only(top:8)
              ),
              titleWidget(
                  text: context.loc.home_title_classement, codelang: codelang),
              const HomeClassement(),
              const SizedBox(height: 20),
              /*Center(
                child: ElevatedButton(
                  onPressed: () {
                    AdMobService.instance.showInterstitialAd();
                  },
                  child: const Text('Show Interstitial Ad'),
                ),
              ),*/
              const SizedBox(height: 20),
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
