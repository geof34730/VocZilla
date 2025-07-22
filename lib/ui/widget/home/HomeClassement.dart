// /Users/geoffreypetain/IdeaProjects/VocZilla-all/voczilla/lib/ui/widget/home/HomeClassement.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/core/utils/device.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/data/models/leaderboard_user.dart';
import 'package:vobzilla/global.dart';
import 'package:vobzilla/main.dart'; // NOUVEAU: Importer main.dart
import 'package:vobzilla/ui/widget/elements/Loading.dart';

import '../../../logic/blocs/leaderboard/leaderboard_bloc.dart';
import '../../../logic/blocs/leaderboard/leaderboard_event.dart';
import '../../../logic/blocs/leaderboard/leaderboard_state.dart';
import 'CardClassementGamer.dart';
import 'CardClassementUser.dart';

class HomeClassement extends StatefulWidget {
  const HomeClassement({super.key});

  @override
  State<HomeClassement> createState() => _HomeClassementState();
}
class _HomeClassementState extends State<HomeClassement> with RouteAware {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
      context.read<LeaderboardBloc>().add(FetchLeaderboard());
      changeVocabulaireSinceVisiteHome = false;
    }
  }

  @override
  void initState() {
    super.initState();
    if (changeVocabulaireSinceVisiteHome) {
      context.read<LeaderboardBloc>().add(FetchLeaderboard());
      changeVocabulaireSinceVisiteHome = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoading || state is LeaderboardInitial) {
          return const Loading();
        }
        if (state is LeaderboardLoaded) {
          return _buildLoaded(context, state.users);
        }
        if (state is LeaderboardError) {
          return _buildError(context, state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoaded(BuildContext context, List<LeaderboardUser> users) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<LeaderboardBloc>().add(FetchLeaderboard());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(builder: (context, constraints) {
          final double spacing = 8.0;
          final int crossAxisCount = isTablet(context) ? 2 : 1;
          final double cardWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

          final List<Widget> gamerCards = users.asMap().entries.map((entry) {
            int index = entry.key;
            var user = entry.value;

            return SizedBox(
              width: cardWidth,
              child: CardClassementGamer(
                position: index + 1,
                user: user,
                // TODO: Rendre cette valeur dynamique
                totalWordsForLevel: 5600,
              ),
            );
          }).toList();

          if (gamerCards.length < 4) {
            gamerCards.add(
              SizedBox(
                width: cardWidth,
                child: CardClassementUser(),
              ),
            );
          }

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: gamerCards,
          );
        }),
      ),
    );
  }

  /// Construit l'UI pour l'état d'erreur, avec un bouton pour réessayer.
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
              onPressed: () {
                context.read<LeaderboardBloc>().add(FetchLeaderboard());
              },
              label: Text("Réessayer"),
            )
          ],
        ),
      ),
    );
  }
}
