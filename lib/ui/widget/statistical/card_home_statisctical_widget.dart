import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/multi_segment_linear_indicator.dart';

import '../../../data/models/statistical_length.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../elements/Error.dart';

class CardHomeStatisticalWidget extends StatefulWidget {
  final Color barColorProgress;
  final Color barColorLeft;
  final EdgeInsetsGeometry paddingLevelBar;
  final double widthWidget;
  final dynamic list;
  final bool isListPerso;
  final bool isListTheme;
  final int? vocabulaireBegin;
  final int? vocabulaireEnd;
  final String local;
  final String listName;



  const CardHomeStatisticalWidget({
    super.key,
    required this.barColorProgress,
    required this.barColorLeft,
    required this.paddingLevelBar,
    required this.widthWidget,
    this.list,
    required this.isListPerso,
    required this.isListTheme,
    this.vocabulaireBegin,
    this.vocabulaireEnd,
    required this.local,
    required this.listName
  });

  @override
  State<CardHomeStatisticalWidget> createState() => _CardHomeStatisticalWidgetState();
}

class _CardHomeStatisticalWidgetState extends State<CardHomeStatisticalWidget> {
  Future<StatisticalLength>? _statisticalFuture;
  StatisticalLength? _lastStatisticalData;





  @override
  void initState() {
    super.initState();
    // Lance le premier chargement si les données utilisateur sont déjà prêtes.
    if (context.read<VocabulaireUserBloc>().state is VocabulaireUserLoaded) {
      _fetchStatisticalData();
    }

  }

  @override
  void didUpdateWidget(CardHomeStatisticalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Rafraîchit les données si les paramètres du widget ont changé.
    if (widget.list != oldWidget.list ||
        widget.isListPerso != oldWidget.isListPerso ||
        widget.isListTheme != oldWidget.isListTheme ||
        widget.vocabulaireBegin != oldWidget.vocabulaireBegin ||
        widget.vocabulaireEnd != oldWidget.vocabulaireEnd) {
      _fetchStatisticalData();
    }
  }

  void _fetchStatisticalData() {
    // Mémorise le Future pour ne pas le recréer à chaque build.
    // On utilise setState pour que le FutureBuilder réagisse au nouveau Future.
    setState(() {
      if (widget.isListPerso || widget.isListTheme) {
        _statisticalFuture = VocabulaireUserRepository().getVocabulaireListDataStatisticalLengthData(
          list: widget.list,
          isListPerso: widget.isListPerso,
          isListTheme: widget.isListTheme,
        );
      } else {
        _statisticalFuture = VocabulaireUserRepository().getVocabulaireUserDataStatisticalLengthData(
          vocabulaireBegin: widget.vocabulaireBegin,
          vocabulaireEnd: widget.vocabulaireEnd,
          isListPerso: widget.isListPerso,
          isListTheme: widget.isListTheme,
          local:widget.local
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VocabulaireUserBloc, VocabulaireUserState>(
      listener: (context, state) {
        // Réagit aux changements des données utilisateur pour rafraîchir les stats.
        if (state is VocabulaireUserLoaded) {
          _fetchStatisticalData();
        }
      },
      builder: (context, state) {
        // Affiche la barre de progression même si les données ne sont pas encore chargées.
        if (state is VocabulaireUserLoaded) {
          return FutureBuilder<StatisticalLength>(
            future: _statisticalFuture,
            builder: (context, userDataSnapshot) {
              // Met en cache les dernières données valides.
              if (userDataSnapshot.hasData) {
                _lastStatisticalData = userDataSnapshot.data;
              }

              // Gère l'erreur de manière non bloquante.
              if (userDataSnapshot.hasError && _lastStatisticalData == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ErrorMessage(context: context, message: 'Erreur de statistique: ${userDataSnapshot.error}');
                });
              }

              // Calcule le pourcentage à afficher en se basant sur les données en cache.
              double percentageProgression = 0.0;
              if (_lastStatisticalData != null) {
                final statisticalData = _lastStatisticalData!;
                if (statisticalData.countVocabulaireAll > 0) {
                  percentageProgression = statisticalData.vocabLearnedCount / statisticalData.countVocabulaireAll;
                }
              }
              if (userDataSnapshot.hasData) {
                VocabulaireUserRepository().checkAndUpdateStatutEndList(listName: widget.listName,percentage: percentageProgression.clamp(0.0, 1.0),context: context);
              }
              // Construit toujours l'indicateur, ce qui évite les sauts d'interface.
              return _buildIndicator(percentage: percentageProgression);
            },
          );
        }

        // Si les données utilisateur sont vides ou pas encore chargées,
        // affiche la barre de progression à 0%.
        if (state is VocabulaireUserEmpty) {
          _lastStatisticalData = null; // Vide le cache
        }
        return _buildIndicator(percentage: 0);
      },
    );
  }

  /// Construit l'indicateur de progression linéaire.
  Widget _buildIndicator({required double percentage}) {
    final clampedPercentage = percentage.clamp(0.0, 1.0);
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 14.0,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 0.5),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: MultiSegmentLinearIndicator(
                padding: EdgeInsets.zero,
                lineHeight: 15.0,
                segments: [
                  if (isRtl)
                    SegmentLinearIndicator(
                      percent: 1.0 - clampedPercentage,
                      color: widget.barColorLeft,
                    ),
                  SegmentLinearIndicator(
                    percent: clampedPercentage,
                    color: widget.barColorProgress,
                    enableStripes: true,
                  ),
                  if (!isRtl)
                    SegmentLinearIndicator(
                      percent: 1.0 - clampedPercentage,
                      color: widget.barColorLeft,
                    ),
                ],
                barRadius: const Radius.circular(5.0),
              ),
            ),
          ),
          Text(
            "${(clampedPercentage * 100).toStringAsFixed(1)}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
