import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';
import '../../../data/models/statistical_length.dart';
import '../../../data/models/vocabulary_user.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
import '../../../data/repository/vocabulaire_repository.dart';
import '../../../data/services/localstorage_service.dart';
import '../../../data/services/vocabulaires_server_service.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../elements/LevelChart.dart';

// Assuming you have a VocabulaireUserBloc and VocabulaireUserState defined

class CardHomeStatisticalWidget extends StatefulWidget {

  final dynamic barColorProgress;
  final dynamic barColorLeft;
  final dynamic paddingLevelBar;
  final double widthWidget;
  final ListPerso? listPerso;
  final int? vocabulaireBegin;
  final int? vocabulaireEnd;



  const CardHomeStatisticalWidget({super.key,

    required this.barColorProgress,
    required this.barColorLeft,
    required this.paddingLevelBar,
    required this.widthWidget,
    this.listPerso,
    this.vocabulaireBegin,
    this.vocabulaireEnd

  });

  @override
  _CardHomeStatisticalWidgetState createState() => _CardHomeStatisticalWidgetState();
}

class _CardHomeStatisticalWidgetState extends State<CardHomeStatisticalWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabulaireUserBloc, VocabulaireUserState>(
      builder: (context, state) {
        if (state is VocabulaireUserLoaded ) {
          return FutureBuilder(
            future: widget.listPerso != null
              ?
              VocabulaireUserRepository().getVocabulaireListPersoDataStatisticalLengthData(
                  listPerso: widget.listPerso
              )
              :
              VocabulaireUserRepository().getVocabulaireUserDataStatisticalLengthData(
                vocabulaireBegin: widget.vocabulaireBegin,
                vocabulaireEnd: widget.vocabulaireEnd,
              )

            ,
            builder: (context, userDataSnapshot) {
              if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Show a loading indicator while waiting
              } else if (userDataSnapshot.hasError) {
                return Text('Erreur affichage Statistique'); // Handle error
              } else if (userDataSnapshot.hasData) {
                StatisticalLength? statisticalData = userDataSnapshot.data;
                return Container(
                  width: widget.widthWidget * 0.90,
                  child:LevelChart(
                    level: statisticalData!.vocabLearnedCount,
                    levelMax: statisticalData.countVocabulaireAll,
                    imageCursor: false,
                    padding: widget.paddingLevelBar,
                    barColorProgress: widget.barColorProgress,
                    barColorLeft: widget.barColorLeft,
                  ),
                );
              } else {
                return Container(
                  width: widget.widthWidget * 0.80,
                  child: LevelChart(
                    level: 0,
                    levelMax: 100,
                    imageCursor: false,
                    padding: widget.paddingLevelBar,
                    barColorProgress: widget.barColorProgress,
                    barColorLeft: widget.barColorLeft,
                  ),
                );
              }
            },
          );
        } else {
          if (state is VocabulaireUserEmpty) {
            return Container(
              width: widget.widthWidget * 0.80,
              child: LevelChart(
                level: 0,
                levelMax: 100,
                imageCursor: false,
                padding: widget.paddingLevelBar,
                barColorProgress: widget.barColorProgress,
                barColorLeft: widget.barColorLeft,
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
