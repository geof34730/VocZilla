import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/logger.dart';
import '../../../data/models/statistical_length.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../elements/LevelChart.dart';

class GlobalStatisticalWidget extends StatelessWidget {
  final int? vocabulaireBegin;
  final int? vocabulaireEnd;

  const GlobalStatisticalWidget({super.key, this.vocabulaireBegin, this.vocabulaireEnd});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabulaireUserBloc, VocabulaireUserState>(
      builder: (context, state) {
        Logger.Yellow.log("BlocBuilder VocabulaireUserBloc $state");
        if (state is VocabulaireUserUpdate || state is VocabulaireUserInitial) {
          Logger.Magenta.log("Update State");
          return FutureBuilder<StatisticalLength>(
            future: VocabulaireUserRepository(context: context).getVocabulairesStatisticalLengthData(
              vocabulaireBegin: vocabulaireBegin,
              vocabulaireEnd: vocabulaireEnd,
            ),
            builder: (context, userDataSnapshot) {
              if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (userDataSnapshot.hasError) {
                return const Text('Erreur affichage Statistique');
              } else if (userDataSnapshot.hasData) {
                final statisticalData = userDataSnapshot.data!;
                return Container(
                  width: double.infinity,
                  child: LevelChart(
                    level: statisticalData.vocabLearnedCount,
                    levelMax: statisticalData.countVocabulaireAll,
                  ),
                );
              } else {
                return Container(
                  width: double.infinity,
                  child: LevelChart(
                    level: 10,
                    levelMax: 100,
                  ),
                );
              }
            },
          );
        } else {
          return const Text('Erreur affichage Statistique');
        }
      },
    );
  }
}
