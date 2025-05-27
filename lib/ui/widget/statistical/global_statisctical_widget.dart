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
  final String? guidListPerso;

  const GlobalStatisticalWidget({super.key, this.vocabulaireBegin, this.vocabulaireEnd, this.guidListPerso});

  @override
  Widget build(BuildContext context) {

    Logger.Pink.log(guidListPerso);

    return BlocBuilder<VocabulaireUserBloc, VocabulaireUserState>(
      builder: (context, state) {
        Logger.Yellow.log("BlocBuilder VocabulaireUserBloc $state");
        if (state is VocabulaireUserLoaded) {


          return FutureBuilder<StatisticalLength>(
            future: VocabulaireUserRepository().getVocabulaireUserDataStatisticalLengthData(
              vocabulaireBegin: vocabulaireBegin,
              vocabulaireEnd: vocabulaireEnd,
              guidListPerso:guidListPerso
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
                    level: 0,
                    levelMax: 100,
                  ),
                );
              }
            },
          );
        } else {
          if (state is VocabulaireUserEmpty) {
            return Container(
              width: double.infinity,
              child: LevelChart(
                level: 0,
                levelMax: 100,
              ),
            );
          }
          else {
            return const Text('Erreur affichage Statistique');
          }
        }
      },
    );
  }
}
