import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/multi_segment_linear_indicator.dart';


import '../../../data/models/statistical_length.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../elements/Error.dart';

class GlobalStatisticalWidget extends StatefulWidget {
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
  State<GlobalStatisticalWidget> createState() => _GlobalStatisticalWidgetState();
}

class _GlobalStatisticalWidgetState extends State<GlobalStatisticalWidget> {
  Future<StatisticalLength>? _statisticalFuture;
  StatisticalLength? _lastStatisticalData;
  static const double _heightIndicator = 50.0;

  @override
  void initState() {
    super.initState();
    // Fetch initial data only if the user data is already loaded.
    if (context.read<VocabulaireUserBloc>().state is VocabulaireUserLoaded) {
      _fetchStatisticalData();
    }
  }

  @override
  void didUpdateWidget(GlobalStatisticalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refetch if widget parameters change
    if (widget.vocabulaireBegin != oldWidget.vocabulaireBegin ||
        widget.vocabulaireEnd != oldWidget.vocabulaireEnd ||
        widget.guidList != oldWidget.guidList ||
        widget.isListPerso != oldWidget.isListPerso ||
        widget.isListTheme != oldWidget.isListTheme) {
      _fetchStatisticalData();
    }
  }

  void _fetchStatisticalData() {
    _statisticalFuture = VocabulaireUserRepository().getVocabulaireUserDataStatisticalLengthData(
      vocabulaireBegin: widget.vocabulaireBegin,
      vocabulaireEnd: widget.vocabulaireEnd,
      guidList: widget.guidList,
      isListPerso: widget.isListPerso,
      isListTheme: widget.isListTheme,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VocabulaireUserBloc, VocabulaireUserState>(
      listener: (context, state) {
        // When user data changes, refetch statistics.
        if (state is VocabulaireUserLoaded) {
          setState(() {
            _fetchStatisticalData();
          });
        }
      },
      builder: (context, state) {
        if (state is VocabulaireUserLoaded) {
          return FutureBuilder<StatisticalLength>(
            future: _statisticalFuture,
            builder: (context, userDataSnapshot) {
              // Cache the latest successful data.
              if (userDataSnapshot.hasData) {
                _lastStatisticalData = userDataSnapshot.data;
              }

              // If an error occurs and we have no cached data, show the error.
              if (userDataSnapshot.hasError && _lastStatisticalData == null) {
                // Il est préférable d'afficher une erreur non bloquante
                // et de quand même rendre le widget dans son état initial.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ErrorMessage(context: context, message: 'Erreur de statistique: ${userDataSnapshot.error}');
                });
              }

              // Déterminer le pourceRntage à afficher.
              // Utiliser les données mises en cache si elles existent, sinon 0.
              double percentageProgression = 0.0;
              if (_lastStatisticalData != null) {
                final statisticalData = _lastStatisticalData!;
                if (statisticalData.countVocabulaireAll > 0) {
                  percentageProgression = statisticalData.vocabLearnedCount / statisticalData.countVocabulaireAll;
                }
              }

              // Toujours construire l'indicateur avec le pourcentage déterminé.
              // Cela couvre les états de chargement, vide, d'erreur (avec affichage de l'ancienne donnée) et de données disponibles.
              return LayoutBuilder(
                builder: (context, constraints) => _buildIndicator(
                  percentage: percentageProgression,
                  width: constraints.maxWidth,
                  context: context,
                ),
              );
            },
          );
        } else if (state is VocabulaireUserEmpty) {
          _lastStatisticalData = null; // Clear cache if user data is empty
          return LayoutBuilder(
            builder: (context, constraints) => _buildIndicator(
              percentage: 0,
              width: constraints.maxWidth,
              context: context,
            ),
          );
        }
        // Default case for other states (initial, error...)
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildIndicator({
    required double percentage,
    required double width,
    required BuildContext context,
  }) {
    final clampedPercentage = percentage.clamp(0.0, 1.0);
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    // Le texte du pourcentage doit s'aligner en s'éloignant du logo.
    // La disposition du texte (gauche/droite) change en fonction du pourcentage.
    final textAlignForBigPercentage = isRtl ? TextAlign.left : TextAlign.right;
    final textAlignForSmallPercentage = isRtl ? TextAlign.right : TextAlign.left;

    return Center(child:Padding(
        padding: EdgeInsets.only(left:30,right:30),
        child:SizedBox(
        height: _heightIndicator,
        child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none, // Permet au logo de déborder sans être coupé
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
                      if (isRtl)
                        SegmentLinearIndicator(
                          percent: 1.0 - clampedPercentage,
                          color: Colors.orange,
                        ),
                      SegmentLinearIndicator(
                        percent: clampedPercentage,
                        color: Colors.green,
                        enableStripes: true,
                      ),
                      if (!isRtl)
                        SegmentLinearIndicator(
                          percent: 1.0 - clampedPercentage,
                          color: Colors.orange,
                        ),
                    ],
                    barRadius: const Radius.circular(5.0),
                  ),
                ),
              ),
              Positioned(
                left: _getPositionLeftCursor(
                    percentage: clampedPercentage,
                    width: width,
                    isRtl: isRtl,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Important pour que la Row ne prenne que la place nécessaire
                  children: [
                    if (clampedPercentage > 0.2) ...[
                      SizedBox(
                        width: 60,
                        child: Text(
                          "${(clampedPercentage * 100).toStringAsFixed(1)}%",
                          textAlign: textAlignForBigPercentage,
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
                      width: 50,
                    ),
                    if (clampedPercentage <= 0.2) ...[
                      const SizedBox(width: 5),
                      SizedBox(
                        width: 60,
                        child: Text(
                          "${(clampedPercentage * 100).toStringAsFixed(1)}%",
                          textAlign: textAlignForSmallPercentage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          )
        )
    ));
  }

  double _getPositionLeftCursor({
    required double percentage,
    required double width,
    required bool isRtl,
  }) {
    // Définir les dimensions et la disposition du curseur
    const double textBlockWidth = 60.0 + 5.0;
    const double imageWidth = 80.0;
    const double cursorRowWidth = textBlockWidth + imageWidth;
    const double halfImageWidth = imageWidth / 2;

    // Déterminer la disposition de la Row en fonction du pourcentage pour trouver le centre du logo
    // isLogoVisuallyFirst est vrai si le logo apparaît en premier (à gauche en LTR, à droite en RTL)
    final bool isLogoVisuallyFirst = (isRtl && percentage > 0.2) || (!isRtl && percentage <= 0.2);
    final double logoCenterOffsetInRow = isLogoVisuallyFirst ? halfImageWidth : textBlockWidth + halfImageWidth;

    // Calculer le point de jonction idéal sur la barre
    final double junctionPoint = isRtl ? width * (1 - percentage) : width * percentage;

    // Calculer la position de départ idéale pour la Row pour centrer le logo sur la jonction
    final double idealPosition = junctionPoint - logoCenterOffsetInRow;

    // Pour que le centre du logo soit sur le point de jonction, la Row doit commencer à: position = point de jonction - décalage du centre du logo
    // On ne contraint plus la position pour permettre au logo de déborder.
    return idealPosition;
  }
}
