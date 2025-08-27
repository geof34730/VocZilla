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
  final String local;

  const GlobalStatisticalWidget({
    super.key,
    this.vocabulaireBegin,
    this.vocabulaireEnd,
    this.guidList,
    required this.isListPerso,
    required this.isListTheme,
    required this.local,
  });

  @override
  State<GlobalStatisticalWidget> createState() => _GlobalStatisticalWidgetState();
}

class _GlobalStatisticalWidgetState extends State<GlobalStatisticalWidget> {
  Future<StatisticalLength>? _statisticalFuture;
  StatisticalLength? _lastStatisticalData;

  // Constantes synchronisées (utilisées partout)
  static const double _heightIndicator = 50.0;
  static const double _hPadding = 20.0;
  static const double _lineHeight = 20.0;
  static const double _textWidth = 60.0;
  static const double _gap = 5.0;
  static const double _logoWidth = 50.0; // doit correspondre à Image.asset(width: 50)

  @override
  void initState() {
    super.initState();
    // Fetch initial data only if the user data is already loaded.
    if (context.read<VocabulaireUserBloc>().state is VocabulaireUserLoaded) {
      _fetchStatisticalData(local: widget.local);
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

      _fetchStatisticalData(local: widget.local);
    }
  }

  void _fetchStatisticalData({required String local}) {
    _statisticalFuture =
        VocabulaireUserRepository().getVocabulaireUserDataStatisticalLengthData(
          vocabulaireBegin: widget.vocabulaireBegin,
          vocabulaireEnd: widget.vocabulaireEnd,
          guidList: widget.guidList,
          isListPerso: widget.isListPerso,
          isListTheme: widget.isListTheme,
          local: local
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VocabulaireUserBloc, VocabulaireUserState>(
      listener: (context, state) {
        // When user data changes, refetch statistics.
        if (state is VocabulaireUserLoaded) {
          setState(() {
            _fetchStatisticalData(local: widget.local);
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

              // If an error occurs and we have no cached data, show the error (non bloquant).
              if (userDataSnapshot.hasError && _lastStatisticalData == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ErrorMessage(
                    context: context,
                    message: 'Erreur de statistique: ${userDataSnapshot.error}',
                  );
                });
              }

              // Déterminer le pourcentage à afficher.
              double percentageProgression = 0.0;
              if (_lastStatisticalData != null) {
                final statisticalData = _lastStatisticalData!;
                if (statisticalData.countVocabulaireAll > 0) {
                  percentageProgression = statisticalData.vocabLearnedCount /
                      statisticalData.countVocabulaireAll;
                }
              }

              // Toujours construire l'indicateur.
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

    final textAlignForBigPercentage = isRtl ? TextAlign.left : TextAlign.right;
    final textAlignForSmallPercentage = isRtl ? TextAlign.right : TextAlign.left;

    // Largeur réellement disponible après padding
    final double availableWidth =
    (width - (_hPadding * 2)).clamp(0.0, double.infinity);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _hPadding),
        child: SizedBox(
          height: _heightIndicator,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none, // autorise le débordement du logo
            children: [
              // Barre d'avancement (utilise availableWidth)
              Container(
                width: availableWidth,
                height: _lineHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 0.5),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: MultiSegmentLinearIndicator(
                    padding: EdgeInsets.zero,
                    lineHeight: _lineHeight,
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

              // Curseur (logo + texte) positionné par rapport à la largeur réelle
              Positioned(
                left: _getPositionLeftCursor(
                  percentage: clampedPercentage,
                  width: availableWidth,
                  isRtl: isRtl,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  // S'assure que l'ordre visuel suit la Directionality
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    if (clampedPercentage > 0.2) ...[
                      SizedBox(
                        width: _textWidth,
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
                      const SizedBox(width: _gap),
                    ],
                    Image.asset(
                      "assets/brand/logo_landing.png",
                      width: _logoWidth, // synchronisé avec le calcul
                    ),
                    if (clampedPercentage <= 0.2) ...[
                      const SizedBox(width: _gap),
                      SizedBox(
                        width: _textWidth,
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
          ),
        ),
      ),
    );
  }

  double _getPositionLeftCursor({
    required double percentage,
    required double width, // largeur réelle (après padding)
    required bool isRtl,
  }) {
    // Largeurs cohérentes avec le rendu réel
    const double textBlockWidth = _textWidth + _gap;
    const double halfImageWidth = _logoWidth / 2;

    // Position de la jonction (à partir du bord gauche de la barre)
    final double junctionPoint =
    isRtl ? width * (1 - percentage) : width * percentage;

    // Le logo apparaît visuellement en premier selon le sens + seuil 0.2
    final bool isLogoVisuallyFirst =
        (isRtl && percentage > 0.2) || (!isRtl && percentage <= 0.2);

    // Décalage du centre du logo dans la Row (depuis son bord "start")
    final double logoCenterOffsetInRow =
    isLogoVisuallyFirst ? halfImageWidth : textBlockWidth + halfImageWidth;

    // Bord gauche de la Row pour centrer le logo exactement sur la jonction
    final double idealLeft = junctionPoint - logoCenterOffsetInRow;

    // Pas de clamp ici pour autoriser le débordement volontaire du logo
    return idealLeft;
  }
}
