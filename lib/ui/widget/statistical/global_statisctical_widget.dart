import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/multi_segment_linear_indicator.dart';

import '../../../data/models/statistical_length.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';

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
    required this.isListTheme,
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
              guidList: guidList,
              isListPerso: isListPerso,
              isListTheme: isListTheme,
            ),
            builder: (context, userDataSnapshot) {
              if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (userDataSnapshot.hasError) {
                // Affiche une erreur plus informative
                return Text('Erreur de statistique: ${userDataSnapshot.error}');
              } else if (userDataSnapshot.hasData) {
                final statisticalData = userDataSnapshot.data!;
                double percentageProgression = 0.0;
                if (statisticalData.countVocabulaireAll > 0) {
                  percentageProgression = statisticalData.vocabLearnedCount / statisticalData.countVocabulaireAll;
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return _buildIndicator(
                      percentage: percentageProgression,
                      width: constraints.maxWidth,
                      context: context
                    );
                  },
                );
              } else {
                // Si pas de données, on affiche une barre de progression à 0%
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return _buildIndicator(
                      percentage: 0,
                      width: constraints.maxWidth,
                      context: context
                    );
                  },
                );
              }
            },
          );
        } else if (state is VocabulaireUserEmpty) {
          // Si l'utilisateur n'a pas de données, on affiche 0%
          return LayoutBuilder(
            builder: (context, constraints) {
              return _buildIndicator(
                percentage: 0,
                width: constraints.maxWidth,
                context: context
              );
            },
          );
        } else {
          // Cas par défaut pour les autres états (initial, erreur...)
          return const SizedBox.shrink();
        }
      },
    );
  }

  /// Construit l'indicateur de progression pour éviter la duplication de code.
  /// Le type de retour est `Widget` pour plus de sûreté.
  Widget _buildIndicator({required double percentage, required double width, required BuildContext context}) {

    const Set<String> _rtlLangs = {'ar', 'fa', 'he', 'ur'};

    bool _isRtlFromAppLocale(BuildContext context) {
      final code = Localizations.localeOf(context).languageCode.toLowerCase();
      return _rtlLangs.contains(code);
    }

    final clampedPercentage = percentage.clamp(0.0, 1.0);
    final bool isRtl = _isRtlFromAppLocale(context);
    return Center(
      child: Stack(
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
                lineHeight: 20.0,
                segments: [
                  if(isRtl)
                    SegmentLinearIndicator(
                      percent: 1.0 - max(0.05, clampedPercentage),
                      color: Colors.orange,
                    ),
                  SegmentLinearIndicator(
                    percent: max(0.05, clampedPercentage),
                    color: Colors.green,
                    enableStripes: true,
                  ),
                  if(!isRtl)
                    SegmentLinearIndicator(
                      percent: 1.0 - max(0.05, clampedPercentage),
                      color: Colors.orange,
                    ),


                ],
                barRadius: const Radius.circular(5.0),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: _getPositionLeftCursor(
                percentage: clampedPercentage,
                width: width,
              ),
            ),
            child: Row(
              children: [
                if (clampedPercentage > 0.2) ...[
                  SizedBox(
                    width: 60,
                    child: Text(
                      "${(clampedPercentage * 100).toStringAsFixed(1)}%",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                Image.asset(
                  "assets/brand/logo_landing.png",
                  width: 80,
                ),
                if (clampedPercentage <= 0.2) ...[
                  const SizedBox(width: 5),
                  Text(
                    "${(clampedPercentage * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getPositionLeftCursor({required double percentage, required double width}) {
    const double cursorRowWidth = 145.0;
    const double imageOffset = 40.0;
    double position = width * percentage - imageOffset;
    return position.clamp(0.0, width - cursorRowWidth);
  }
}
