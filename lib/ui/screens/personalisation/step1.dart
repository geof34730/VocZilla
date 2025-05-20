import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/data/models/vocabulary_user.dart';
import 'package:vobzilla/logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import 'package:vobzilla/logic/blocs/vocabulaires/vocabulaires_event.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';

import '../../../core/utils/enum.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repository/vocabulaire_repository.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../../logic/notifiers/button_notifier.dart';
var uuid = const Uuid();
class PersonnalisationStep1Screen extends StatelessWidget {
  late final String? guidListPerso;
  PersonnalisationStep1Screen({super.key,this.guidListPerso});
  final titleList = TextEditingController();
  String  guidListGenerate = uuid.v4();
  Color colorList = Colors.purple;
  late ButtonNotifier buttonNotifier = ButtonNotifier();
  @override
  Widget build(BuildContext context) {
    final  finalGuidList = guidListPerso ?? guidListGenerate;
    final statutListPerso statutForm = guidListPerso != null ? statutListPerso.edit : statutListPerso.create;

    return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(finalGuidList),
          Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              child: TextFormField(
                  controller: titleList,
                  maxLength: 50,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Titre de votre liste",
                    labelText: "Titre de votre liste",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  ),
                  onChanged: (value) {
                    changeText(value: value);
                  }
                  )
          ),

          Padding(
             padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Text(
               "Choisissez la couleur de votre liste",
                style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    )
                ),
              )),
          Padding(
              padding: EdgeInsets.only(left: 20,right: 20,top:10.00,bottom:10.0),
              child:MaterialColorPicker(
                allowShades: true,
                onlyShadeSelection: false,
                onColorChange: (Color color) {
                  colorList = color;
                },
                selectedColor: colorList,
              )),

            Center(
              child:AnimatedBuilder(
                animation: buttonNotifier,
                builder: (context, child) {
                  return buttonNotifier.showButton
                      ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        next(
                            statutForm: statutForm,
                            context: context,
                            guidListPerso: finalGuidList
                        );
                      },
                      child: Text(context.loc.button_next),
                    ),
                  )
                      : Container();
                },
              ),
            )

        ]
    );
  }


  changeText({required String value}){
    if(value!=""){
      buttonNotifier.updateButtonState(true);
    }
    else{
      buttonNotifier.updateButtonState(false);
    }
  }

  next({required statutListPerso statutForm, required BuildContext context, required String guidListPerso}) {
    if (statutForm == statutListPerso.create) {
      ///CREATION NOUVELLE LIST PERSO
      Logger.Green.log("CREATION NOUVELLE LIST PERSO");
      final ListPerso newListPerso = ListPerso(
        guid: guidListGenerate,
        title: titleList.text,
        color: colorList.value,
      );
      BlocProvider.of<VocabulaireUserBloc>(context).add(AddListPerso(newListPerso));
      BlocProvider.of<VocabulairesBloc>(context).add(getAllVocabulaire(false,guidListPerso));
      Navigator.pushNamed(context, "/personnalisation/step2/$guidListGenerate");
    }
    if (statutForm == statutListPerso.edit) {
      //MISE A JOUR DE LA LISTE PERSO
      Logger.Green.log("MISE A JOUR DE LA LISTE PERSO");
    }
  }


}


