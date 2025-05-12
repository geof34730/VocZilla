import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';
import '../../../data/models/statistical_length.dart';
import '../../../data/models/vocabulary_user.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
import '../../../data/services/localstorage_service.dart';
import '../../../data/services/vocabulaires_server_service.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../elements/LevelChart.dart';

// Assuming you have a VocabulaireUserBloc and VocabulaireUserState defined

class GlobalStatisticalWidget extends StatefulWidget {
  final dynamic userDataSpecificList;

  const GlobalStatisticalWidget({super.key, List<dynamic>? this.userDataSpecificList});

  @override
  _GlobalStatisticalWidgetState createState() => _GlobalStatisticalWidgetState();
}

class _GlobalStatisticalWidgetState extends State<GlobalStatisticalWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabulaireUserBloc, VocabulaireUserState>(
      builder: (context, state) {
        Logger.Yellow.log("BlocBuilder VocabulaireUserBloc $state");
        if (state is VocabulaireUserUpdate || state is VocabulaireUserInitial) {
          Logger.Magenta.log("Update State");
          // Assuming getUserData() returns a Future
          return FutureBuilder(
            future: VocabulaireUserRepository(context: context).getVocabulairesStatisticalLengthData(
                userDataSpecificList:widget.userDataSpecificList
            ),
            builder: (context, userDataSnapshot) {
              if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Show a loading indicator while waiting
              } else if (userDataSnapshot.hasError) {
                return Text('Erreur affichage Statistique'); // Handle error
              } else if (userDataSnapshot.hasData) {
                StatisticalLength? statisticalData = userDataSnapshot.data;
                return Container(
                  width: double.infinity,
                  child: LevelChart(
                    level: statisticalData!.vocabLearnedCount,
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
          return Text('Erreur affichage Statistique');
        }
      },
    );
  }



}

/*
class GlobalStatisticalWidget extends StatefulWidget {
  @override
  _GlobalStatisticalWidgetState createState() => _GlobalStatisticalWidgetState();
}

class _GlobalStatisticalWidgetState extends State<GlobalStatisticalWidget> {
  int vocabLearnedCount = 0;
  int vocabAllCount = 0;

  @override
  Widget build(BuildContext context) {

    return Container(
        width: double.infinity,
        child: LevelChart(
          level: vocabLearnedCount,
          levelMax: 100,
        ),
      );

  }
}

*/
