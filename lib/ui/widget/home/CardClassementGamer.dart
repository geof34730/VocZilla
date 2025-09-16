// /Users/geoffreypetain/IdeaProjects/VocZilla-all/voczilla/lib/ui/widget/home/CardClassementGamer.dart

import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/multi_segment_linear_indicator.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/data/models/leaderboard_user.dart';

import '../../../core/utils/getFontForLanguage.dart';
import '../../../core/utils/logger.dart';

class CardClassementGamer extends StatelessWidget {
  final int position;
  final LeaderboardUser user;
  final int totalWordsForLevel;
  final int countTrophy;


  const CardClassementGamer({
    super.key,
    required this.position,
    required this.user,
    required this.totalWordsForLevel,
    required this.countTrophy
  });

  /// Helper pour construire l'avatar à partir d'une image Base64 ou d'un fallback.
  Widget _buildAvatar() {
    // Si la chaîne de l'avatar n'est pas vide, on essaie de la décoder.
    if (user.imageAvatar.isNotEmpty) {
      try {
        final imageBytes = base64Decode(user.imageAvatar);
        return CircleAvatar(
          radius: 30,
          backgroundImage: MemoryImage(imageBytes),
          backgroundColor: Colors.white, // Couleur de fond si l'image est transparente
        );
      } catch (e) {
        // En cas d'erreur de décodage, on utilise le fallback
        return Avatar(
          radius: 30,
          name: user.pseudo,
          fontsize: 20,
        );
      }
    }
    // Si la chaîne est vide, on utilise directement le fallback.
    return Avatar(
      radius: 30,
      name: user.pseudo,
      fontsize: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysSinceCreation = DateTime.now().difference(user.createdAt).inDays;
    final percentage = (totalWordsForLevel > 0)
        ? user.countGuidVocabularyLearned / totalWordsForLevel
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: 280,

          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Card(
                clipBehavior: Clip.hardEdge, // coupe ce qui dépasse
                elevation: 8,
                color: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SizedBox(
                  height: 135,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ligne du haut
                      Padding(
                        padding: const EdgeInsets.only(top: 10,left:8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: SvgPicture.asset(
                                  "assets/svg/trophy_${position.toString()}.svg",
                                  width: 50,
                                ),
                            ),
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(right:5,top: 5),
                              child: _buildAvatar(),
                            ),
                            const SizedBox(width: 5),
                            // Zone texte compressible
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      "${user.pseudo}",
                                      maxLines: 1,
                                      textAlign: TextAlign.start,
                                      style: getFontForLanguage(
                                        codelang: Localizations.localeOf(context).languageCode,
                                        fontSize: 20,
                                      ).copyWith(color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '$daysSinceCreation ${context.loc.card_home_user_day}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${user.listPersoCount} ${context.loc.card_home_user_liste_perso}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Center(
                        child:Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: LayoutBuilder(
                          builder: (ctx, innerConstraints) {
                            return Center(
                              child: getLinearPercentIndicator(
                                percentage: percentage,
                                width: innerConstraints.maxWidth,
                                context: context,
                              ),
                            );
                          },
                        ),
                      ),
                      ),


                    ],
                  ),
                ),

              ),
              Positioned(
                top: -6, // ajuste selon besoin
                right: -6,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      SvgPicture.asset(
                        "assets/svg/achievement-award-medal-icon.svg",
                        height: 40,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            border: Border.all(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child:  Text(
                            countTrophy.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },

    );
  }
// ... existing code ...

  // Le reste de votre code (getLinearPercentIndicator, getPositionLeftCursor) reste inchangé
  Widget getLinearPercentIndicator({required double percentage, required double width, required BuildContext context}) {
    final clampedPercentage = percentage.clamp(0.0, 1.0);
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    // Le texte du pourcentage doit s'aligner en s'éloignant du logo.
    // La disposition du texte (gauche/droite) change en fonction du pourcentage.
    final textAlignForBigPercentage = isRtl ? TextAlign.left : TextAlign.right;
    final textAlignForSmallPercentage = isRtl ? TextAlign.right : TextAlign.left;

    return SizedBox(
        height: 30.0, // Pour permettre au logo de déborder verticalement
        child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none, // Permet au logo de déborder sans être coupé
            children: [
              Container(
                width: width,
                height: 20.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0), color: Colors.grey),
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
                        color: Colors.white,
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
                left: getPositionLeftCursor(
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
                            color: Colors.black,
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
                            color: Colors.black,
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
    );
  }

  double getPositionLeftCursor({
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

    final double junctionPoint = isRtl ? width * (1 - percentage) : width * percentage;

    final double idealPosition = junctionPoint - logoCenterOffsetInRow;

    return idealPosition;
  }
}
