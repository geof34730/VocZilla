import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../global.dart';

final player = AudioPlayer();
class PlaySoond{
  final String stringVocabulaire;
  late double sizeIcon;
  late double sizeButton;
  late Color iconColor;
  late Color buttonColor;
  late IconData iconData;

  PlaySoond({
    required this.stringVocabulaire,
    this.sizeIcon =25,
    this.sizeButton =25,
    this.iconColor=Colors.white,
    this.buttonColor=Colors.blueGrey,
    this.iconData=Icons.volume_up,
  });

  buttonPlay({String typeAudio = 'all'}){
    return CircleAvatar(
          radius: sizeButton,
          backgroundColor: buttonColor,
          child: iconPlay()
        );
  }

  iconPlay(){
    return IconButton(
      key: UniqueKey(),
      icon:  Icon(
        iconData,
        color: iconColor,
        size:sizeIcon
      ),
      onPressed: () {
        playAudio(stringVocabulaire: stringVocabulaire);
      },
    );
  }


  void playAudio({required String stringVocabulaire}) async{
    await player.stop();
    await player.play(AssetSource('audios/gcloud/${stringVocabulaire}.mp3'));
  }

}
