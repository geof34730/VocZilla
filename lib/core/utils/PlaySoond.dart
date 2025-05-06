import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../global.dart';

final player = AudioPlayer();
class PlaySoond {
  final String guidVocabulaire;
  late double sizeButton;
  late Color iconColor;
  late Color buttonColor;
  late IconData iconData;
  late Function? onpressedActionSup;

  PlaySoond({
    required this.guidVocabulaire,
    this.sizeButton = 25,
    this.iconColor = Colors.white,
    this.buttonColor = Colors.blueGrey,
    this.iconData = Icons.volume_up,
    this.onpressedActionSup,
  });

  Widget buttonPlay() {
    print("PlaySoond buttonPlay ${guidVocabulaire}");
    return Material(
      shape: CircleBorder(),
      color: buttonColor, // Background color of the CircleAvatar
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: () {
          playAudio(stringVocabulaire: guidVocabulaire);
          if (onpressedActionSup != null) {
            onpressedActionSup!();
          }
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
