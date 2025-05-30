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
import '../../../logic/notifiers/statutForm_notifier.dart';
var uuid = const Uuid();
class PersonnalisationStep1Screen extends StatelessWidget {
  late final String? guidListPerso;
  PersonnalisationStep1Screen({super.key,this.guidListPerso});
  final titleList = TextEditingController();
  String  guidListGenerate = uuid.v4();
  final ValueNotifier<Color> colorListNotifier = ValueNotifier<Color>(Colors.purple);
  late ButtonNotifier buttonNotifier = ButtonNotifier();
  late StatutFormNotifier statutFormNotifier = StatutFormNotifier();
  @override
  Widget build(BuildContext context) {
    final  finalGuidList = guidListPerso ?? guidListGenerate;
    statutFormNotifier.updateStatutFormState(guidListPerso != null ? statutListPerso.edit : statutListPerso.create);
    if (statutFormNotifier.statutForm == statutListPerso.edit) {
      VocabulaireUserRepository().getListPerso(guidListPerso: guidListPerso ?? "").then((value){
        titleList.text = value!.title;
        colorListNotifier.value = Color(value.color);
        buttonNotifier.updateButtonState(true);
      });
    }
    return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              child: TextFormField(
                  controller: titleList,
                  maxLength: 50,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: context.loc.personnalisation_step1_title_list,
                    labelText: context.loc.personnalisation_step1_title_list,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  ),
                  onChanged: (value) {
                    changeText(
                        value: value,

                        guidListPerso: finalGuidList,
                        context: context
                    );
                  }
                  )
          ),

          Padding(
             padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Text(
               context.loc.personnalisation_step1_color_choice,
                style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    )
                ),
              )),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10.00, bottom: 10.0),
            child: ValueListenableBuilder<Color>(
              valueListenable: colorListNotifier,
              builder: (context, color, child) {
                return MaterialColorPicker(
                  allowShades: true,
                  onlyShadeSelection: false,
                  onColorChange: (Color color) {
                    colorListNotifier.value = color;
                    save(

                        guidListPerso: finalGuidList,
                        context: context
                    );
                  },
                  selectedColor: color,
                );
              },
            ),
          ),

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


  changeText({ required BuildContext context, required String guidListPerso,required String value}){
    Logger.Red.log("statutForm: ${statutFormNotifier.statutForm}");
    if(value!=""){
      save(context: context,guidListPerso: guidListPerso);
      buttonNotifier.updateButtonState(true);
    }
    else{
      buttonNotifier.updateButtonState(false);
    }
  }


  save({ required BuildContext context, required String guidListPerso}){
    if (statutFormNotifier.statutForm == statutListPerso.create) {
      ///CREATION NOUVELLE LIST PERSO
      Logger.Green.log("CREATION NOUVELLE LIST PERSO");
      final ListPerso newListPerso = ListPerso(
        guid: guidListGenerate,
        title: titleList.text,
        color: colorListNotifier.value.value,
      );
      statutFormNotifier.updateStatutFormState(statutListPerso.edit);
      BlocProvider.of<VocabulaireUserBloc>(context).add(AddListPerso(newListPerso));
    }
    if (statutFormNotifier.statutForm == statutListPerso.edit) {
      //MISE A JOUR DE LA LISTE PERSO
      Logger.Green.log("MISE A JOUR DE LA LISTE PERSO");
      final ListPerso updateListPerso = ListPerso(
        guid: guidListPerso,
        title: titleList.text,
        color: colorListNotifier.value.value,
      );
      BlocProvider.of<VocabulaireUserBloc>(context).add(UpdateListPerso(updateListPerso));
    }
    BlocProvider.of<VocabulairesBloc>(context).add(getAllVocabulaire(false,guidListPerso));
  }

  next({required BuildContext context, required String guidListPerso}) {
    Navigator.pushReplacementNamed(context, "/personnalisation/step2/$guidListPerso");
  }


}


