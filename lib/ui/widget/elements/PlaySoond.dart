import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';



final player = AudioPlayer();
class PlaySoond{

  late Map dataVerbe;
  final String typeAudio;
  late double sizeIcon;
  late double sizeButton;
  late Color iconColor;
  late Color buttonColor;

  PlaySoond({
    required this.dataVerbe,
    required this.typeAudio,
    this.sizeIcon =25,
    this.sizeButton =25,
    this.iconColor=Colors.white,
    this.buttonColor=Colors.blueGrey
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
          Icons.volume_up,
          color: iconColor,
          size:sizeIcon
      ),
      onPressed: () {
        playAudio(typeAudio: typeAudio);
      },
    );
  }


  void playAudio({required String typeAudio}) async{
    await player.stop();
    //await player.play(AssetSource('audios/gcloud/${getFilesname()}.mp3'));

  }

  String getFilesname(){
    String FilesName="";
    switch (typeAudio) {
      case "all":
        FilesName= "${dataVerbe['infinitif']} / ${dataVerbe['pastSimple']} / ${dataVerbe['pastParticipe']}".replaceAll(RegExp(r' / '), '_');
        break;
      case "infinitif":
        FilesName= "${dataVerbe['infinitif']}".replaceAll(RegExp(r' / '), '_');
        break;
      case "pastSimple":
        FilesName= "${dataVerbe['pastSimple']}".replaceAll(RegExp(r' / '), '_');
        break;
      case "pastParticipe":
        FilesName= "${dataVerbe['pastParticipe']}".replaceAll(RegExp(r' / '), '_');
        break;
      case "titreVerbe":
        FilesName= "${dataVerbe['titreVerbe']}".replaceAll(RegExp(r' / '), '_'); {}
        break;
    }
    return FilesName.toLowerCase();
  }
}
