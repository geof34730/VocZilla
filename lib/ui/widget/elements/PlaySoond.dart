// lib/ui/widget/elements/PlaySoond.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

final player = AudioPlayer();

class PlaySoond {
  final String guidVocabulaire;
  final double sizeButton;
  final Color iconColor;
  final Color buttonColor;
  final IconData iconData;
  final VoidCallback? onpressedActionSup;

  PlaySoond({
    required this.guidVocabulaire,
    this.sizeButton = 25,
    this.iconColor = Colors.white,
    this.buttonColor = Colors.blueGrey,
    this.iconData = Icons.volume_up,
    this.onpressedActionSup,
  });

  Widget buttonPlay() {
    return Material(
      shape: const CircleBorder(),
      color: buttonColor,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          // On exécute d'abord l'action supplémentaire (annuler l'enregistrement)
          if (onpressedActionSup != null) {
            // CORRECTION CRITIQUE : Appel de la fonction avec les parenthèses ()
            onpressedActionSup!();
          }
          // Puis on joue le son
          playAudio(guidVocabulaire: guidVocabulaire);
        },
        child: CircleAvatar(
          radius: sizeButton,
          backgroundColor: Colors.transparent,
          child: Icon(
            iconData,
            color: iconColor,
            size: sizeButton,
          ),
        ),
      ),
    );
  }

  void playAudio({required String guidVocabulaire}) async {
    await player.stop();
    await player.play(AssetSource('audios/gcloud/$guidVocabulaire.mp3'));
  }
}
