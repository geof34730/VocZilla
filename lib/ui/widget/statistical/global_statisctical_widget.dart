import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/multi_segment_linear_indicator.dart';

import '../../../core/utils/logger.dart';
import '../../../data/models/statistical_length.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import 'LevelChart.dart';

class GlobalStatisticalWidget extends StatelessWidget {
  final int? vocabulaireBegin;
  final int? vocabulaireEnd;
  final String? guidList;
  final bool isListPerso;
  final bool isListTheme;

  const GlobalStatisticalWidget({
    super.key,
    this.vocabulaireBegin,
    this.vocabulaireEnd,
    this.guidList,
    required this.isListPerso,
    required this.isListTheme

  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabulaireUserBloc, VocabulaireUserState>(
      builder: (context, state) {
        if (state is VocabulaireUserLoaded) {
          return FutureBuilder<StatisticalLength>(
            future: VocabulaireUserRepository().getVocabulaireUserDataStatisticalLengthData(
              vocabulaireBegin: vocabulaireBegin,
              vocabulaireEnd: vocabulaireEnd,
              guidList:guidList,
              isListPerso:isListPerso,
              isListTheme:isListTheme,
            ),
            builder: (context, userDataSnapshot) {
              if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (userDataSnapshot.hasError) {
                return const Text('Erreur affichage Statistique');
              } else if (userDataSnapshot.hasData) {
                final statisticalData = userDataSnapshot.data!;
                double percentageProgression = ((statisticalData.vocabLearnedCount / statisticalData.countVocabulaireAll));
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return getLinearPercentIndicator(
                        percentage: percentageProgression,
                        width:constraints.maxWidth
                    );
                  });
              } else {
                return LayoutBuilder(
                    builder: (context, constraints) {
                      return getLinearPercentIndicator(
                          percentage: 0,
                          width:constraints.maxWidth
                      );
                    });
              }
            },
          );
        } else {
          if (state is VocabulaireUserEmpty) {
            return LayoutBuilder(
                builder: (context, constraints) {
                  return getLinearPercentIndicator(
                      percentage: 0,
                      width:constraints.maxWidth
                  );
                });
          }
          else {
            return const Text('Erreur affichage Statistique');
          }
        }
      },
    );
  }

  dynamic getLinearPercentIndicator({required double percentage , required double width}){
    return Center(
        child:Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: width,
              height: 20.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 0.5),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: MultiSegmentLinearIndicator(
                  padding: EdgeInsets.zero,
                  width: double.infinity,
                  lineHeight: 20.0,
                  segments: [
                    SegmentLinearIndicator(
                      percent: max(0.05,percentage),
                      color: Colors.green,
                      enableStripes: true,
                    ),
                    SegmentLinearIndicator(
                      percent: 1.0 - max(0.05,percentage),
                      color: Colors.orange,
                    ),
                  ],
                  barRadius: Radius.circular(5.0),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left:getPositionLeftCursor(
                  percentage: percentage,
                  width: width
              )),
              child:Row(
                children: [
                    if(percentage>0.2)...[
                        Container(
                          padding: EdgeInsets.only(right:5),
                           width: 60,
                           child:Text(
                            "${(percentage * 100).toStringAsFixed(1)}%",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              )
                           ),
                        )
                    ],
                  Image.asset("assets/brand/logo_landing.png",
                    width: 80,
                  ),
                    if(percentage<=0.2)...[
                      Text(
                        "${(percentage * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ]
               ],
              )
            )
          ],
        )
    );
  }

  double getPositionLeftCursor({required double percentage, required double width}){
    double position = width * percentage - (percentage > 0.2 ? 120 : 40);
    return max(0, min(position, width - 140));
  }

}
