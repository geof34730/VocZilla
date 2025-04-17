import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../global.dart';

final player = AudioPlayer();
class PlaySoond {
  final String stringVocabulaire;
  late double sizeButton;
  late Color iconColor;
  late Color buttonColor;
  late IconData iconData;

  PlaySoond({
    required this.stringVocabulaire,
    this.sizeButton = 25,
    this.iconColor = Colors.white,
    this.buttonColor = Colors.blueGrey,
    this.iconData = Icons.volume_up,
  });

  Widget buttonPlay() {
    return Material(
      shape: CircleBorder(),
      color: buttonColor, // Background color of the CircleAvatar
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: () {
          playAudio(stringVocabulaire: stringVocabulaire);
        },
        child: CircleAvatar(
          radius: sizeButton,
          backgroundColor: Colors.transparent, // Make the CircleAvatar transparent
          child: Icon(
            iconData,
            color: iconColor,
            size: sizeButton, // Adjust the size relative to the button size
          ),
        ),
      ),
    );
  }

  void playAudio({required String stringVocabulaire}) async {
    await player.stop();
    await player.play(AssetSource('audios/gcloud/${stringVocabulaire}.mp3'));
  }
}
