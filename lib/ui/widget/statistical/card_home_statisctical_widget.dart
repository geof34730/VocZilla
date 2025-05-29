import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:percent_indicator/multi_segment_linear_indicator.dart';
import '../../../data/models/statistical_length.dart';
import '../../../data/models/vocabulary_user.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import 'LevelChart.dart';



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
                double percentageProgression = ((statisticalData!.vocabLearnedCount / statisticalData.countVocabulaireAll));
                return getLinearPercentIndicator(percentage: percentageProgression);
              } else {
                return getLinearPercentIndicator(percentage: 0);
              }
            },
          );
        } else {
          if (state is VocabulaireUserEmpty) {
            return getLinearPercentIndicator(percentage: 0);
          }
          else {
            return const Text('Erreur affichage Statistique');
          }
        }
      },
    );
  }

  dynamic getLinearPercentIndicator({required double percentage}){
    return Center(
        child:Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width:  double.infinity,
              height: 14.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 0.5),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: MultiSegmentLinearIndicator(
                  padding: EdgeInsets.zero,
                  width: double.infinity,
                  lineHeight: 15.0,
                  segments: [
                    SegmentLinearIndicator(
                      percent: percentage,
                      color: widget.barColorProgress,
                      enableStripes: true,
                    ),
                    SegmentLinearIndicator(
                      percent: 1.0 - percentage,
                      color: widget.barColorLeft,
                    ),
                  ],
                  barRadius: Radius.circular(5.0),
                ),
              ),
            ),
            Text(
              "${(percentage * 100).toStringAsFixed(1)}%",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )

    );
  }


}
