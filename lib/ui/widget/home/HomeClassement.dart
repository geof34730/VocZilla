import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voczilla/core/utils/device.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/data/models/leaderboard_data.dart';
import 'package:voczilla/global.dart';
import 'package:voczilla/main.dart'; // NOUVEAU: Importer main.dart pour routeObserver
import 'package:voczilla/ui/widget/elements/Loading.dart';

import '../../../core/utils/languageUtils.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
import '../../../logic/blocs/leaderboard/leaderboard_bloc.dart';
import '../../../logic/blocs/leaderboard/leaderboard_event.dart';
import '../../../logic/blocs/leaderboard/leaderboard_state.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';

import 'CardClassementGamer.dart';
import 'CardClassementUser.dart';

class HomeClassement extends StatefulWidget {
  const HomeClassement({super.key});

  @override
  State<HomeClassement> createState() => _HomeClassementState();
}

// --- CORRECTION 1 : Ajouter le mixin RouteAware ---
class _HomeClassementState extends State<HomeClassement> with RouteAware {

  @override
  void initState() {
    super.initState();

  }
 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    if (changeVocabulaireSinceVisiteHome) {
      _fetchData();
      changeVocabulaireSinceVisiteHome = false;
    }
  }

  void _fetchData() {
    final langCode = LanguageUtils.getSmallCodeLanguage(context: context);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<LeaderboardBloc>().add(FetchLeaderboard(local: langCode));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoading || state is LeaderboardInitial) {
          return Padding(
              padding:EdgeInsets.only(top:30,bottom:30),
              child:Loading()
            );
        }
        if (state is LeaderboardLoaded) {
          return Padding(
              padding:EdgeInsets.only(top:4,bottom:15),
              child:_buildLoaded(context, state.leaderboardData)
          );
        }
        if (state is LeaderboardError) {
          return _buildError(context, state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoaded(BuildContext context, LeaderboardData data) {

    return LayoutBuilder(builder: (context, constraints) {
      final double spacing = 6.0;
      final int crossAxisCount = isTablet(context) ? 2 : 1;
      final double cardWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

      final List<Widget> gamerCards = data.topUsers.map((user) {
        return SizedBox(
          width: cardWidth,
          child: CardClassementGamer(
            position: user.rank,
            user: user,
            totalWordsForLevel: data.totalWordsInLevel,
            countTrophy: user.countTrophy,
          ),
        );
      }).toList();

      gamerCards.add(
        SizedBox(
          width: cardWidth,
          child: CardClassementUser(position: data.currentUserRank),
        ),
      );

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: gamerCards,
      );
    });
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${context.loc.error_loading}:\n$message",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchData,
              label: Text(context.loc.card_home_reessayer),
            )
          ],
        ),
      ),
    );
  }
}
