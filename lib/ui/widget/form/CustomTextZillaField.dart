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
  final bool resultSound;
  final bool AnswerNotifier;
  final bool ButtonNextNotifier;
  final ButtonNotifier? buttonNotifier;

  const CustomTextZillaField({
    Key? key,
    required this.ControlerField,
    required this.labelText,
    required this.resulteField,
    this.buttonNotifier,
    this.voidCallBack,
    required this.GUID,
    this.resultSound = false,
    this.AnswerNotifier = false,
    this.ButtonNextNotifier = false,
  }) : super(key: key);

  @override
  _CustomTextZillaFieldState createState() => _CustomTextZillaFieldState();
}

class _CustomTextZillaFieldState extends State<CustomTextZillaField> {
  String _previousValue = "";
  bool _answeredByUser = true;
  bool _isAutoFill = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _answeredByUser = true;
    _isAutoFill = false;
    _isInitializing = true;
    _previousValue = "";
    widget.buttonNotifier?.updateButtonState(false);
    widget.ControlerField.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isInitializing = false;
    });
  }

  @override
  void dispose() {
    widget.ControlerField.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (_isInitializing) return;

    final value = widget.ControlerField.text;

    if (_isAutoFill) {
      _answeredByUser = false;
      _isAutoFill = false;
    } else {
      _answeredByUser = true;
    }

    // Si l'utilisateur efface du texte, on met juste à jour l'état et on sort.
    if (value.length < _previousValue.length) {
      _previousValue = value;
      setState(() {});
      return;
    }

    String correctText = widget.resulteField;
    String newText = value;

    // --- Logique d'auto-correction des accents ---
    // On l'applique seulement s'il n'y a pas de réponses multiples (pas de "/")
    if (!correctText.contains("/") && value.isNotEmpty) {
      String normalizedInput = removeDiacritics(value.toUpperCase());
      String normalizedCorrect = removeDiacritics(correctText.toUpperCase());

      // Si le début de la saisie normalisée correspond au début de la réponse normalisée
      if (normalizedCorrect.startsWith(normalizedInput)) {
        // On remplace la saisie par la version correctement accentuée
        newText = correctText.substring(0, value.length);
      }
    }

    _previousValue = newText;

    // On met à jour le contrôleur seulement si le texte a changé, pour éviter une boucle infinie.
    if (widget.ControlerField.text != newText) {
      widget.ControlerField.value = TextEditingValue(
        text: newText,
        selection: TextSelection.fromPosition(TextPosition(offset: newText.length)),
      );
      // Le listener sera rappelé par cette modification, donc on sort pour éviter de faire le travail deux fois
      return;
    }

    // On met à jour l'état pour que l'interface (icônes, bordures) se redessine.
    setState(() {});

    // --- Logique de succès ---
    if (getSuccesField(controllerField: widget.ControlerField, stockValue: widget.resulteField)) {
      // On utilise un post-frame callback pour s'assurer que le build est terminé
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
          if (widget.AnswerNotifier) {
            AnswerNotifier(context).markAsAnsweredCorrectly(
              isAnswerUser: _answeredByUser,
              guidVocabulaire: widget.GUID,
              local: Localizations.localeOf(context).languageCode,
            );
          }
          if (widget.ButtonNextNotifier) {
            widget.buttonNotifier?.updateButtonState(true);
          }
          if (widget.voidCallBack != null) {
            widget.voidCallBack!();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.00),
      child: TextFormField(
        readOnly: getSuccesField(controllerField: widget.ControlerField, stockValue: widget.resulteField),
        enabled: true,
        controller: widget.ControlerField,
        maxLength: widget.resulteField.length,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        style: TextStyle(
          color: Colors.black,
        ),
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          icon: writeContentAndStyleIcon(controllerField: widget.ControlerField, stockValue: widget.resulteField),
          hintText: widget.labelText,
          labelText: widget.labelText,
          labelStyle: TextStyle(
            color: Colors.grey,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: getBorderColor(controllerField: widget.ControlerField, stockValue: widget.resulteField)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: getBorderColor(controllerField: widget.ControlerField, stockValue: widget.resulteField)),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 2, color: Colors.green),
            borderRadius: BorderRadius.circular(5),
          ),
          suffixIcon: (getSuccesField(controllerField: widget.ControlerField, stockValue: widget.resulteField)
              ? (
              widget.resultSound
                  ? PlaySoond(
                guidVocabulaire: widget.GUID,
                sizeButton: 20,
                buttonColor: Colors.transparent,
                iconColor: Colors.black,
              ).buttonPlay()
                  : null
          )
              : IconButton(
            icon: Icon(Icons.visibility, color: getBorderColor(controllerField: widget.ControlerField, stockValue: widget.resulteField)),
            onPressed: () {
              _isAutoFill = true;
              widget.ControlerField.text = widget.resulteField;
            },
          )
          ),
        ),
      ),
    );
  }

  Icon writeContentAndStyleIcon({required TextEditingController controllerField, required String stockValue}) {
    if (controllerField.text.isNotEmpty) {
      if (getErrorField(controllerField: controllerField, stockValue: stockValue)) {
        return const Icon(Icons.error, color: Colors.red);
      }
    }
    if (getSuccesField(controllerField: controllerField, stockValue: stockValue)) {
      return const Icon(Icons.check, color: Colors.green);
    }
    return const Icon(Icons.question_answer, color: Colors.blue);
  }

  Color getBorderColor({required TextEditingController controllerField, required String stockValue}) {
    if (controllerField.text.isNotEmpty) {
      if (getErrorField(controllerField: controllerField, stockValue: stockValue)) {
        return Colors.red;
      }
    }
    if (getSuccesField(controllerField: controllerField, stockValue: stockValue)) {
      return Colors.green;
    }
    return Colors.blue;
  }

  String removeDiacritics(String str) {
    const withDia =    'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    const withoutDia = 'AAAAAAaaaaaaOOOOOOooooooEEEEeeeedCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }

  String stockValueNoDescription({required String stockValue}) {
    String newStockValue = stockValue;
    if (newStockValue.contains('(')) {
      // Supprime tout ce qui se trouve entre parenthèses
      newStockValue = newStockValue.replaceAll(RegExp(r'\s*\([^)]*\)\s*'), ' ').trim();
    }
    return newStockValue;
  }

  bool getErrorField({required TextEditingController controllerField, required String stockValue}) {
    String controllerValue = controllerField.text;
    if (controllerValue.isEmpty) return false; // Pas d'erreur si le champ est vide

    // Nettoie les réponses (enlève les descriptions et les accents)
    String cleanStock = removeDiacritics(stockValueNoDescription(stockValue: stockValue).toUpperCase());
    String cleanController = removeDiacritics(stockValueNoDescription(stockValue: controllerValue).toUpperCase());

    // Gère les réponses multiples séparées par "/"
    if (cleanStock.contains('/')) {
      List<String> stockParts = cleanStock.split('/').map((p) => p.trim()).toList();
      List<String> controllerParts = cleanController.split('/').map((p) => p.trim()).toList();

      if (controllerParts.length > stockParts.length) return true; // Plus de parties que possible

      for (int i = 0; i < controllerParts.length; i++) {
        // La dernière partie peut être une saisie partielle
        if (i == controllerParts.length - 1) {
          if (!stockParts[i].startsWith(controllerParts[i])) {
            return true; // La saisie partielle ne correspond pas
          }
        } else {
          // Les parties précédentes doivent correspondre exactement
          if (stockParts[i] != controllerParts[i]) {
            return true;
          }
        }
      }
      return false; // Tout va bien jusqu'ici
    }

    // Cas simple (une seule réponse)
    return !cleanStock.startsWith(cleanController);
  }

  bool getSuccesField({required TextEditingController controllerField, required String stockValue}) {
    // Le succès est atteint quand les versions nettoyées (sans description ni accent) sont identiques.
    String cleanStock = removeDiacritics(stockValueNoDescription(stockValue: stockValue).toUpperCase());
    String cleanController = removeDiacritics(stockValueNoDescription(stockValue: controllerField.text).toUpperCase());
    return cleanStock == cleanController;
  }
}
