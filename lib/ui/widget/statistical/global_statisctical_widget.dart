import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:percent_indicator/multi_segment_linear_indicator.dart';
import 'package:voczilla/core/utils/localization.dart';

import '../../../core/utils/logger.dart';
import '../../../data/models/statistical_length.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../elements/Error.dart';

import '../home/TitleWidget.dart';

class GlobalStatisticalWidget extends StatefulWidget {
  final int? vocabulaireBegin;
  final int? vocabulaireEnd;
  final String? guidList;
  final bool isListPerso;
  final bool isListTheme;
  final String local;
  final String? listName;
  final String title;
  final bool showTrophy;

  const GlobalStatisticalWidget({
    super.key,
    this.vocabulaireBegin,
    this.vocabulaireEnd,
    this.guidList,
    this.showTrophy = true,
    required this.isListPerso,
    required this.isListTheme,
    required this.local,
    required this.listName,
    required this.title,
  });

  @override
  State<GlobalStatisticalWidget> createState() => _GlobalStatisticalWidgetState();
}

class _GlobalStatisticalWidgetState extends State<GlobalStatisticalWidget> {
  Future<StatisticalLength>? _statisticalFuture;
  StatisticalLength? _lastStatisticalData;

  // Dimensions (centralisées)
  static const double _hPadding = 20.0;
  static const double _lineHeight = 20.0; // hauteur de la barre
  static const double _textWidth = 60.0;  // largeur réservée au %
  static const double _gap = 5.0;
  static const double _cursorSize = 50.0; // taille du logo (carré)

  int countTrophyState = 0;

  @override
  void initState() {
    super.initState();
    final blocState = context.read<VocabulaireUserBloc>().state;
    if (blocState is VocabulaireUserLoaded) {
      _fetchStatisticalData(local: widget.local);
      countTrophyState = getTrophyTopLength(dataListDefinedEnd: blocState.data.ListDefinedEnd);
    }
  }

  @override
  void didUpdateWidget(GlobalStatisticalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Rafraîchir quand les props changent
    if (widget.vocabulaireBegin != oldWidget.vocabulaireBegin ||
        widget.vocabulaireEnd != oldWidget.vocabulaireEnd ||
        widget.guidList != oldWidget.guidList ||
        widget.isListPerso != oldWidget.isListPerso ||
        widget.isListTheme != oldWidget.isListTheme ||
        widget.local != oldWidget.local) {
      _fetchStatisticalData(local: widget.local);
    }
  }

  void _fetchStatisticalData({required String local}) {
    final future = VocabulaireUserRepository().getVocabulaireUserDataStatisticalLengthData(
      vocabulaireBegin: widget.vocabulaireBegin,
      vocabulaireEnd: widget.vocabulaireEnd,
      guidList: widget.guidList,
      isListPerso: widget.isListPerso,
      isListTheme: widget.isListTheme,
      local: local,
    );

    // Gérer le trophée une fois les données chargées
    future.then((statisticalData) {
      if (!mounted || widget.listName == null) return;

      double percentageProgression = 0.0;
      if (statisticalData.countVocabulaireAll > 0) {
        percentageProgression =
            statisticalData.vocabLearnedCount / statisticalData.countVocabulaireAll;
      }

      final bloc = context.read<VocabulaireUserBloc>();
      if (bloc.state is VocabulaireUserLoaded) {
        final currentState = bloc.state as VocabulaireUserLoaded;
        final bool isAlreadyCompleted =
        currentState.data.ListDefinedEnd.contains(widget.listName);

        if (percentageProgression == 1.0 && !isAlreadyCompleted) {
          bloc.add(AddCompletedDefinedList(listName: widget.listName!, local: widget.local));
        } else if (percentageProgression < 1.0 && isAlreadyCompleted) {
          bloc.add(RemoveCompletedDefinedList(listName: widget.listName!, local: widget.local));
        }
      }
    });

    _statisticalFuture = future;
  }

  int getTrophyTopLength({required List<String> dataListDefinedEnd}) {
    return dataListDefinedEnd.where((item) => item.startsWith('top')).length;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VocabulaireUserBloc, VocabulaireUserState>(
      listener: (context, state) {
        if (state is VocabulaireUserLoaded) {
          setState(() {
            _fetchStatisticalData(local: widget.local);
            countTrophyState =
                getTrophyTopLength(dataListDefinedEnd: state.data.ListDefinedEnd);
          });
        }
      },
      builder: (context, state) {
        if (state is VocabulaireUserLoaded) {
          return FutureBuilder<StatisticalLength>(
            future: _statisticalFuture,
            builder: (context, userDataSnapshot) {
              if (userDataSnapshot.hasData) {
                _lastStatisticalData = userDataSnapshot.data;
              }

              if (userDataSnapshot.hasError && _lastStatisticalData == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ErrorMessage(
                    context: context,
                    message: 'Erreur de statistique: ${userDataSnapshot.error}',
                  );
                });
              }

              double percentageProgression = 0.0;
              if (_lastStatisticalData != null) {
                final statisticalData = _lastStatisticalData!;
                if (statisticalData.countVocabulaireAll > 0) {
                  percentageProgression =
                      statisticalData.vocabLearnedCount / statisticalData.countVocabulaireAll;
                }
              }

              return LayoutBuilder(
                builder: (context, constraints) => _buildIndicator(
                  percentage: percentageProgression,
                  width: constraints.maxWidth,
                  context: context,
                  countTrophy: countTrophyState,
                ),
              );
            },
          );
        } else if (state is VocabulaireUserEmpty) {
          _lastStatisticalData = null;
          return LayoutBuilder(
            builder: (context, constraints) => _buildIndicator(
              percentage: 0,
              width: constraints.maxWidth,
              context: context,
              countTrophy: countTrophyState,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildIndicator({
    required double percentage,
    required double width,
    required BuildContext context,
    required int countTrophy,
  }) {
    final clampedPercentage = percentage.clamp(0.0, 1.0);
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    final textAlignForBigPercentage = isRtl ? TextAlign.left : TextAlign.right;
    final textAlignForSmallPercentage = isRtl ? TextAlign.right : TextAlign.left;

    // Largeur disponible (hors padding horizontal)
    final double availableWidth = (width - (_hPadding * 2)).clamp(0.0, double.infinity);

    // Hauteur réelle du bloc indicateur (barre + curseur)
    final double heightIndicator = max(_lineHeight, _cursorSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
                child: Container(
                  constraints: BoxConstraints(minWidth: 100, maxWidth: MediaQuery.of(context).size.width - 60),
                  child: titleWidget(
                    text:  widget.title,
                    codelang: Localizations.localeOf(context).languageCode,
                    maxLine: 1
                  ),
                )
            ),
            if (widget.showTrophy) ...[
              const SizedBox(width: 10),
              Badge.count(
                offset: const Offset(8, 0),
                padding: const EdgeInsets.only(left: 5, right: 5),
                backgroundColor: Colors.green,
                count: countTrophy,
                child: SvgPicture.asset(
                  "assets/svg/achievement-award-medal-icon.svg",
                  height: 30,
                ),
              ),
            ],

          ],
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _hPadding),
            child: SizedBox(
              height: heightIndicator,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // BARRE DE PROGRESSION
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
                        segments: isRtl
                            ? [
                          // RTL: reste (gauche) puis acquis (droite)
                          SegmentLinearIndicator(
                            percent: 1.0 - clampedPercentage,
                            color: Colors.orange,
                          ),
                          SegmentLinearIndicator(
                            percent: clampedPercentage,
                            color: Colors.green,
                            enableStripes: true,
                          ),
                        ]
                            : [
                          // LTR: acquis (gauche) puis reste (droite)
                          SegmentLinearIndicator(
                            percent: clampedPercentage,
                            color: Colors.green,
                            enableStripes: true,
                          ),
                          SegmentLinearIndicator(
                            percent: 1.0 - clampedPercentage,
                            color: Colors.orange,
                          ),
                        ],
                        barRadius: const Radius.circular(5.0),
                      ),
                    ),
                  ),

                  // CURSEUR (logo + texte)
                  Positioned(
                    left: _getPositionLeftCursor(
                      percentage: clampedPercentage,
                      width: availableWidth,
                      isRtl: isRtl,
                    ),
                    // Centre verticalement pour éviter tout "vide" en dessous
                    top: (heightIndicator - max(_cursorSize, _lineHeight)) / 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                          width: _cursorSize,
                          height: _cursorSize,
                          fit: BoxFit.contain,
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
        )
      ],
    );
  }

  double _getPositionLeftCursor({
    required double percentage,
    required double width, // largeur réelle (après padding)
    required bool isRtl,
  }) {
    const double textBlockWidth = _textWidth + _gap;
    const double halfImageWidth = _cursorSize / 2;

    // Position de la jonction (à partir du bord gauche)
    final double junctionPoint = isRtl ? width * (1 - percentage) : width * percentage;

    // Le logo apparaît visuellement en premier selon le sens + seuil 0.2
    final bool isLogoVisuallyFirst = (isRtl && percentage > 0.2) || (!isRtl && percentage <= 0.2);

    final double logoCenterOffsetInRow =
    isLogoVisuallyFirst ? halfImageWidth : textBlockWidth + halfImageWidth;

    final double idealLeft = junctionPoint - logoCenterOffsetInRow;

    return idealLeft; // pas de clamp: débordement volontaire ok
  }
}
