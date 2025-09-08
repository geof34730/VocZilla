import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/data/models/vocabulary_user.dart';
import 'package:voczilla/logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import 'package:voczilla/logic/blocs/vocabulaires/vocabulaires_event.dart';

import '../../../core/utils/enum.dart';
import '../../../core/utils/languageUtils.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../../logic/notifiers/button_notifier.dart';
import '../../../logic/notifiers/statutForm_notifier.dart';
var uuid = const Uuid();
class PersonnalisationStep1Screen extends StatefulWidget {
  final String? guidListPerso;
  const PersonnalisationStep1Screen({super.key,this.guidListPerso});

  @override
  State<PersonnalisationStep1Screen> createState() => _PersonnalisationStep1ScreenState();
}

class _PersonnalisationStep1ScreenState extends State<PersonnalisationStep1Screen> {
  final titleList = TextEditingController();
  final String  guidListGenerate = uuid.v4();
  final ValueNotifier<Color> colorListNotifier = ValueNotifier<Color>(Colors.purple);
  final ButtonNotifier buttonNotifier = ButtonNotifier();
  final StatutFormNotifier statutFormNotifier = StatutFormNotifier();
  late final String finalGuidList;
  Timer? _debounce;
  bool _isLoading = false;
  bool _isInit = false;
  final _vocabulaireUserRepository = VocabulaireUserRepository();

  @override
  void initState() {
    super.initState();
    finalGuidList = widget.guidListPerso ?? guidListGenerate;
    // The logic that depends on context has been moved to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) return;

    final isEditing = widget.guidListPerso != null;
    statutFormNotifier.updateStatutFormState(isEditing ? statutListPerso.edit : statutListPerso.create);

    if (isEditing) {
      _vocabulaireUserRepository.getListPerso(guidListPerso: widget.guidListPerso!, local: LanguageUtils.getSmallCodeLanguage(context: context)).then((value){
        if (value != null && mounted) {
          titleList.text = value.title;
          colorListNotifier.value = Color(value.color);
          buttonNotifier.updateButtonState(true);
        }
      });
    }
    _isInit = true;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    titleList.dispose();
    colorListNotifier.dispose();
    buttonNotifier.dispose();
    statutFormNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        key: ValueKey('perso_list_step1'),
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              child: TextFormField(
                  key: ValueKey('title_perso_field'),
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
                    _changeText(
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
              // key: ValueKey('color_picker_builder'), // You could add a key here too if needed for the builder
              builder: (context, color, child) {
                return MaterialColorPicker(
                  key: ValueKey('color_picker'),
                  allowShades: true,
                  onlyShadeSelection: false,
                  onColorChange: (Color color) {
                    colorListNotifier.value = color;
                    _save(
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
                      key: ValueKey('button_valide_step_perso'),
                      onPressed: _isLoading ? null : () {
                        _saveAndNavigate(
                          context: context,
                          guidListPerso: finalGuidList,
                        );
                      },
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            )
                          : Text(context.loc.button_next),
                    ),
                  )
                      : Container();
                },
              ),
            )

        ]
    );
  }


  _changeText({ required BuildContext context, required String guidListPerso,required String value}){
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      Logger.Red.log("statutForm: ${statutFormNotifier.statutForm}");
      if(value.isNotEmpty){
        _save(context: context,guidListPerso: guidListPerso);
        buttonNotifier.updateButtonState(true);
      }
      else{
        buttonNotifier.updateButtonState(false);
      }
    });
  }


  _save({ required BuildContext context, required String guidListPerso}){
    if (statutFormNotifier.statutForm == statutListPerso.create) {
      ///CREATION NOUVELLE LIST PERSO
      Logger.Green.log("CREATION NOUVELLE LIST PERSO");
      final ListPerso newListPerso = ListPerso(
        guid: guidListGenerate,
        title: titleList.text,
        color: colorListNotifier.value.value,
      );
      statutFormNotifier.updateStatutFormState(statutListPerso.edit);
      BlocProvider.of<VocabulaireUserBloc>(context).add(AddListPerso( listPerso: newListPerso, local: LanguageUtils.getSmallCodeLanguage(context: context)));
    } else if (statutFormNotifier.statutForm == statutListPerso.edit) {
      //MISE A JOUR DE LA LISTE PERSO
      Logger.Green.log("MISE A JOUR DE LA LISTE PERSO");
      final ListPerso updateListPerso = ListPerso(
        guid: guidListPerso,
        title: titleList.text,
        color: colorListNotifier.value.value,
      );
      BlocProvider.of<VocabulaireUserBloc>(context).add(UpdateListPerso(listPerso: updateListPerso,local: LanguageUtils.getSmallCodeLanguage(context: context)));
    }
    BlocProvider.of<VocabulairesBloc>(context).add(getAllVocabulaire( isVocabularyNotLearned: false, guid: guidListPerso, local: LanguageUtils.getSmallCodeLanguage(context: context)));
  }

  Future<void> _saveAndNavigate({required BuildContext context, required String guidListPerso}) async {
    setState(() {
      _isLoading = true;
    });

    // Annule tout debounce en attente pour s'assurer que nous ne sauvegardons pas deux fois.
    _debounce?.cancel();

    // Sauvegarde explicite des données avant de naviguer.
    _save(context: context, guidListPerso: guidListPerso);

    // Ajout d'un petit délai pour que l'utilisateur voie le loader et pour donner
    // le temps au BLoC de traiter les événements avant la navigation.
    await Future.delayed(const Duration(milliseconds: 750));

    if (mounted) {
      _next(context: context, guidListPerso: guidListPerso);
    }
  }

  _next({required BuildContext context, required String guidListPerso}) {
    Navigator.pushReplacementNamed(context, "/personnalisation/step2/$guidListPerso");
  }

}
