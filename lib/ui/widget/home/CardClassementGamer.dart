// /Users/geoffreypetain/IdeaProjects/VocZilla-all/voczilla/lib/ui/widget/home/CardClassementGamer.dart

import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/multi_segment_linear_indicator.dart';
import 'package:vobzilla/data/models/leaderboard_user.dart';

class CardClassementGamer extends StatelessWidget {
  final int position;
  final LeaderboardUser user;
  final int totalWordsForLevel;

  const CardClassementGamer({
    super.key,
    required this.position,
    required this.user,
    required this.totalWordsForLevel,
  });

  /// Helper pour construire l'avatar à partir d'une image Base64 ou d'un fallback.
  Widget _buildAvatar() {
    // Si la chaîne de l'avatar n'est pas vide, on essaie de la décoder.
    if (user.imageAvatar.isNotEmpty) {
      try {
        final imageBytes = base64Decode(user.imageAvatar);
        return CircleAvatar(
          radius: 15,
          backgroundImage: MemoryImage(imageBytes),
          backgroundColor: Colors.white, // Couleur de fond si l'image est transparente
        );
      } catch (e) {
        // En cas d'erreur de décodage, on utilise le fallback
        return Avatar(
          radius: 15,
          name: user.pseudo,
          fontsize: 20,
        );
      }
    }
    // Si la chaîne est vide, on utilise directement le fallback.
    return Avatar(
      radius: 15,
      name: user.pseudo,
      fontsize: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculs dynamiques basés sur les données de l'utilisateur
    final daysSinceCreation = DateTime.now().difference(user.createdAt).inDays;
    final percentage = (totalWordsForLevel > 0)
        ? user.countGuidVocabularyLearned / totalWordsForLevel
        : 0.0;

    return LayoutBuilder(builder: (context, constraints) {
      return Card(
          color: Colors.green,
          child: ListTile(
            leading: SizedBox(
              width: 40,
              child: Center( // Simplifié pour un meilleur centrage
                child: AutoSizeText(
                  position.toString(),
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontFamily: GoogleFonts.titanOne().fontFamily),
                  maxLines: 1,
                  minFontSize: 10,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // Meilleur alignement vertical
                  children: [
                    _buildAvatar(), // Utilisation de l'avatar dynamique
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user.pseudo, // Pseudo dynamique
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: GoogleFonts.titanOne().fontFamily,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              '$daysSinceCreation jour(s)', // Ancienneté dynamique
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              )),
                          Text(
                              '${user.listPersoCount} liste(s) Perso', // Listes dynamiques
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              )),
                        ]),
                  ],
                ),
                const SizedBox(height: 4),
                LayoutBuilder(builder: (context, constraints) {
                  return getLinearPercentIndicator(
                      percentage: percentage, // Pourcentage dynamique
                      width: constraints.maxWidth);
                })
              ],
            ),
          ));
    });
  }

  // Le reste de votre code (getLinearPercentIndicator, getPositionLeftCursor) reste inchangé
  dynamic getLinearPercentIndicator({required double percentage, required double width}) {
    return Center(
        child: Stack(
          alignment: Alignment.center,
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
                  width: double.infinity,
                  lineHeight: 20.0,
                  segments: [
                    SegmentLinearIndicator(
                      percent: max(0.05, percentage),
                      color: Colors.white,
                      enableStripes: true,
                    ),
                    SegmentLinearIndicator(
                      percent: 1.0 - max(0.05, percentage),
                      color: Colors.orange,
                    ),
                  ],
                  barRadius: const Radius.circular(5.0),
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                    left: getPositionLeftCursor(
                        percentage: percentage, width: width)),
                child: Row(
                  children: [
                    if (percentage > 0.2) ...[
                      SizedBox(
                        width: 60,
                        child: Text(
                            "${(percentage * 100).toStringAsFixed(1)}%",
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )),
                      )
                    ],
                    Image.asset(
                      "assets/brand/logo_landing.png",
                      width: 80,
                    ),
                    if (percentage <= 0.2) ...[
                      Text(
                        "${(percentage * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  ],
                ))
          ],
        ));
  }

  double getPositionLeftCursor(
      {required double percentage, required double width}) {
    double position = width * percentage - (percentage > 0.2 ? 120 : 40);
    return max(0, min(position, width - 140));
  }
}
