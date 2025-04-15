import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';

import '../../../core/utils/PlaySoond.dart';
import '../../widget/form/CustomTextZillaField.dart';

class VoiceDictationScreen extends StatefulWidget {


  VoiceDictationScreen();

  @override
  _VoiceDictationScreenState createState() => _VoiceDictationScreenState();
}

class _VoiceDictationScreenState extends State<VoiceDictationScreen> {
  late TextEditingController customeTextZillaControllerDictation = TextEditingController();
  bool buttonNext = false;

  @override
  void initState() {
    super.initState();
   // customeTextZillaControllerDictation = TextEditingController();
  }

  @override
  void dispose() {
    customeTextZillaControllerDictation.dispose();
    super.dispose();
  }

  late int i=0;

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: PlaySoond(
              stringVocabulaire:"0a0ca447-3106-449f-aa9e-4489a3cf8135",
              sizeIcon: 150,
              sizeButton:100,
              buttonColor: Colors.green,
              iconData: Icons.play_arrow
          ).buttonPlay(),
        ),
        CustomTextZillaField(
          ControlerField: customeTextZillaControllerDictation,
          labelText: context.loc.dictation_label_text_field,
          hintText: 'Saisissez les textes que vous entendez',
          resulteField: 'boy',
          resultSound:false,
          voidCallBack: () {
            print('***************************ok retour ${i}');
            if(i== 0){
              i++;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  buttonNext = true;
                });
              });
            }
          },
        ),
        if (buttonNext)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text("boy = garçon",
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (buttonNext)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
              onPressed: () {
                print('next');
              },
              child: Text('Suivant'),
            ),
          ),
      ],
    );
  }
}
