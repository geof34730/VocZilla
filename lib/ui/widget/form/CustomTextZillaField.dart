import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../elements/PlaySoond.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/notifiers/answer_notifier.dart';
import '../../../logic/notifiers/button_notifier.dart';


class CustomTextZillaField extends StatefulWidget {
  final TextEditingController ControlerField;
  final String labelText;
  final String resulteField;
  final String GUID;
  final dynamic Function()? voidCallBack;
  bool resultSound;
  bool AnswerNotifier;
  bool ButtonNextNotifier;

  final ButtonNotifier? buttonNotifier;

  CustomTextZillaField({
    required this.ControlerField,
    required this.labelText,
    required this.resulteField,
    this.buttonNotifier,
    this.voidCallBack,
    required this.GUID ,
    this.resultSound = false,
    this.AnswerNotifier =false,
    this.ButtonNextNotifier =false,
  });

  @override
  _CustomTextZillaFieldState createState() => _CustomTextZillaFieldState();
}

class _CustomTextZillaFieldState extends State<CustomTextZillaField> {

  @override
  void initState() {
    widget.buttonNotifier?.updateButtonState(false);
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.00),
        child: TextFormField(
          readOnly: widget.ControlerField.text.toUpperCase() == widget.resulteField.toUpperCase(),
          enabled:true,
          controller: widget.ControlerField,
          maxLength: widget.resulteField.length,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          onChanged: (value) {
            if (widget.ControlerField.text.length <= widget.resulteField.length) {
              setState(() { });
            }
            if(widget.ControlerField.text.toUpperCase() == widget.resulteField.toUpperCase()){
              if(widget.AnswerNotifier) {
                AnswerNotifier(
                    context
                ).markAsAnsweredCorrectly(
                  isAnswerUser: true,
                  guidVocabulaire: widget.GUID,
                );
              }
              if(widget.ButtonNextNotifier) {
                widget.buttonNotifier?.updateButtonState(true);
              }
              if(widget.voidCallBack != null){
                widget.voidCallBack!();
              }
            }
          },
          style: TextStyle(
            color: Colors.black, // Changez la couleur ici
          ),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              icon: writeContentAndStyleIcon(controllerField: widget.ControlerField, stockValue: widget.resulteField),
              hintText: widget.labelText,
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: Colors.grey // Utilisez la couleur du label ici
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: getBorderColor(controllerField: widget.ControlerField, stockValue: widget.resulteField))),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: getBorderColor(controllerField: widget.ControlerField, stockValue: widget.resulteField))),
              disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 2, color: Colors.green),
                borderRadius: BorderRadius.circular(5),

              ),
              suffixIcon: (widget.ControlerField.text.toUpperCase() == widget.resulteField.toUpperCase()
                  ? (
                  widget.resultSound
                      ?
                      PlaySoond(guidVocabulaire: widget.GUID, sizeButton: 20,buttonColor: Colors.transparent,iconColor: Colors.black).buttonPlay()
                      :

                      null
              )
                  : IconButton(
                icon: Icon(Icons.visibility, color: getBorderColor(controllerField: widget.ControlerField, stockValue: widget.resulteField)),
                onPressed: () {
                  widget.ControlerField.text = widget.resulteField;
                  if(widget.AnswerNotifier) {
                    AnswerNotifier(
                        context
                      ).markAsAnsweredCorrectly(
                        isAnswerUser: false,
                        guidVocabulaire: widget.GUID,
                      );
                  }
                  if(widget.ButtonNextNotifier) {
                    widget.buttonNotifier?.updateButtonState(true);
                  }

                  if(widget.voidCallBack != null){
                    widget.voidCallBack!();
                  }
                  setState(() {
                    //widget.updateStateParent();
                  });
                },
              ))),
        ));
  }



  Icon writeContentAndStyleIcon({required TextEditingController controllerField, required String stockValue}) {
    if (stockValue.contains("/")) {
      dynamic arrayVerb = stockValueNoDescription(stockValue: stockValue).split(" / ");
      for (var verb in arrayVerb) {
        if (controllerField.text.toUpperCase().indexOf(' / ') > 0) {
          int posNewSaisiVerbe = controllerField.text.toUpperCase().indexOf(' / ') + 3;
          int nbSeparatorVerb = '/'.allMatches(stockValue).length;
          //JUSTE SECOND VERB
          if (nbSeparatorVerb > '/'.allMatches(controllerField.text).length) {
            String newText = controllerField.text.substring(posNewSaisiVerbe, controllerField.text.length);
            if (newText.toUpperCase() == verb.toUpperCase()) {
              controllerField.value = TextEditingValue(
                text: "${controllerField.text} / ",
                selection: TextSelection.collapsed(offset: "${controllerField.text} / ".length),
              );
            }
          }
        } else {
          if (controllerField.text.toUpperCase() == verb.toUpperCase()) {
            controllerField.value = TextEditingValue(
              text: "$verb / ",
              selection: TextSelection.collapsed(offset: "$verb / ".length),
            );
          }
        }
      }
    }
    if (controllerField.text != '') {
      if (getErrorField(controllerField: controllerField, stockValue: stockValue)) {
        return const Icon(Icons.error, color: Colors.red);
      }
    }
    if (controllerField.text == "") {
      return const Icon(Icons.question_answer, color: Colors.blue);
    }
    if (getSuccesField(controllerField: controllerField, stockValue: stockValue)) {
      controllerField.value = TextEditingValue(
        text: stockValue,
        selection: TextSelection.collapsed(offset: stockValue.length),
      );
      return const Icon(Icons.check, color: Colors.green);
    } else {
      return const Icon(Icons.question_answer, color: Colors.blue);
    }
  }

  Color getBorderColor({required TextEditingController controllerField, required String stockValue}) {
    if (controllerField.text != '') {
      if (getErrorField(controllerField: controllerField, stockValue: stockValue)) {
        return Colors.red;
      }
    }
    if (controllerField.text == "") {
      return Colors.blue;
    }
    if (getSuccesField(controllerField: controllerField, stockValue: stockValue)) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  bool getErrorField({required TextEditingController controllerField, required String stockValue}) {
    String controllerValue = controllerField.text.toUpperCase();
    stockValue = stockValue.toUpperCase();
    dynamic arrayVerb = stockValueNoDescription(stockValue: stockValue).split(" / ");
    if (stockValue.contains("/")) {
      if (!controllerField.text.contains("/")) {
        ///FIRST VERB EN SAISIE IN THE FIELD
        for (var verb in arrayVerb) {
          if (verb.length >= stockValueNoDescription(stockValue: controllerValue).length) {
            if (verb.substring(0, stockValueNoDescription(stockValue: controllerValue).length) == stockValueNoDescription(stockValue: controllerValue)) {
              return false;
            }
          }
        }
        return true;
      } else {
        dynamic arrayVerbControllerField = stockValueNoDescription(stockValue: controllerField.text).split(" / ");

        ///SECOND VERB EN SAISIE IN THE FIELD
        for (var verb in arrayVerb) {
          int positionSaisie2 = stockValueNoDescription(stockValue: controllerValue).indexOf(' / ') + 3;
          if (controllerValue.length > positionSaisie2) {
            String saisie2 = stockValueNoDescription(stockValue: controllerValue).substring(positionSaisie2, stockValueNoDescription(stockValue: controllerValue).length);
            if (saisie2.indexOf('/') > 0) {
              // saisie 3
              int positionSaisie3 = saisie2.indexOf(' / ') + 3;
              String saisie3 = saisie2.substring(positionSaisie3, saisie2.length);
              for (var verb in arrayVerb) {
                if (verb.indexOf(saisie3) >= 0) {
                  return false;
                }
              }
              return true;
            } else {
              //saisie 2
              for (var verb in arrayVerb) {
                if (verb.indexOf(saisie2) >= 0) {
                  int nbSeparatorVerb = '/'.allMatches(stockValue).length;
                  return false;
                }
              }
              return true;
            }
          } else {
            return false;
          }
        }
      }
    } else {
      String cleanControllerValue = stockValueNoDescription(stockValue: controllerValue);
      String cleanStockValue = stockValueNoDescription(stockValue: stockValue);
      if (cleanControllerValue.length > cleanStockValue.length) {
        return true;
      }
      return cleanStockValue.substring(0, cleanControllerValue.length) != cleanControllerValue;
    }
    return false;
  }

  bool getSuccesField({required TextEditingController controllerField, required String stockValue}) {

    String controllerValue = controllerField.text.toUpperCase();
    stockValue = stockValue.toUpperCase();
    dynamic arrayVerb = stockValueNoDescription(stockValue: stockValue).split(" / ");
    if (stockValue.contains("/")) {
      if (!controllerField.text.contains("/")) {
        ///FIRST VERB EN SAISIE IN THE FIELD
        for (var verb in arrayVerb) {
          if (verb.length >= stockValueNoDescription(stockValue: controllerValue).length) {
            if (verb.substring(0, stockValueNoDescription(stockValue: controllerValue).length) == stockValueNoDescription(stockValue: controllerValue)) {
              return false;
            }
          }
        }
      } else {
        ///SECOND VERB EN SAISIE IN THE FIELD
        dynamic arrayVerbControllerField = stockValueNoDescription(stockValue: controllerField.text).split(" / ");
        for (var verb in arrayVerb) {
          int positionSaisie2 = stockValueNoDescription(stockValue: controllerValue).indexOf(' / ') + 3;
          if (controllerValue.length > positionSaisie2) {
            String saisie2 = stockValueNoDescription(stockValue: controllerValue).substring(positionSaisie2, stockValueNoDescription(stockValue: controllerValue).length);
            if (saisie2.indexOf('/') > 0) {
              //saisie 3
              int positionSaisie3 = saisie2.indexOf(' / ') + 3;
              String saisie3 = saisie2.substring(positionSaisie3, saisie2.length);
              for (var verb in arrayVerb) {
                if (saisie3 != "" && verb.toUpperCase() == saisie3.toUpperCase()) {
                  return true;
                }
              }
              return false;
            } else {
              for (var verb in arrayVerb) {
                if (verb.toUpperCase() == saisie2.toUpperCase()) {
                  int nbSeparatorVerb = '/'.allMatches(stockValue).length;
                  if (nbSeparatorVerb == 1) {
                    return true;
                  }
                }
              }
            }
            return false;
          } else {
            return false;
          }
        }
        return false;
      }
      return false;
    }
    return stockValueNoDescription(stockValue: controllerValue) == stockValueNoDescription(stockValue: stockValue);
  }

  String stockValueNoDescription({required stockValue}) {
    if (stockValue.indexOf('(') >= 0) {
      int nbDescriptionVerb = '('.allMatches(stockValue).length;
      String newStockValue = stockValue;
      for (var i = 0; i < nbDescriptionVerb; i = i + 1) {
        int positionBeginDescription = newStockValue.indexOf('(') - 1;
        int positionEndDescription = newStockValue.indexOf(')') + 1;
        String stringDelete = newStockValue.substring(positionBeginDescription, positionEndDescription);
        newStockValue = newStockValue.replaceAll(stringDelete, '');
      }
      return newStockValue;
      //return removeDiacritics(newStockValue);
    } else {
      return stockValue;
      //return removeDiacritics(stockValue);
    }
  }
}
