// lib/ui/screens/vocabulary/quizz_screen.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/core/utils/localization.dart';
import '../../../core/utils/languageUtils.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';
import '../../widget/elements/LevelChart.dart';
import '../../widget/form/CustomTextZillaField.dart';
import '../../../logic/notifiers/button_notifier.dart'; // Importez ici

class QuizzScreen extends StatefulWidget {
  QuizzScreen();

  @override
  _QuizzScreenState createState() => _QuizzScreenState();
}

class _QuizzScreenState extends State<QuizzScreen> {
  late TextEditingController customeTextZillaControllerLearnLocalLanguage = TextEditingController();
  late TextEditingController customeTextZillaControllerLearnEnglishLanguage = TextEditingController();
  late ButtonNotifier buttonNotifier = ButtonNotifier();

  late bool refrechRandom = true;
  int randomItemData = 0;

  @override
  void dispose() {
    customeTextZillaControllerLearnLocalLanguage.dispose();
    customeTextZillaControllerLearnEnglishLanguage.dispose();
    buttonNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabulairesBloc, VocabulairesState>(
      builder: (context, state) {
        if (state is VocabulairesLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is VocabulairesLoaded) {
          if (state.data.isEmpty) {
            return Center(child: Text(context.loc.no_vocabulary_items_found));
          }
          final List<dynamic> data = state.data["vocabulaireList"] as List<dynamic>;
          if (data.isEmpty) {
            return Center(child: Text(context.loc.no_vocabulary_items_found));
          }
          if (refrechRandom) {
            refrechRandom = false;
            Random random = new Random();
            randomItemData = random.nextInt(data.length);
            switch (Random().nextInt(2)) {
              case 0:
                {
                  customeTextZillaControllerLearnLocalLanguage.text = data[randomItemData][LanguageUtils().getSmallCodeLanguage(context: context)];
                }
                break;
              case 1:
                {
                  customeTextZillaControllerLearnEnglishLanguage.text = data[randomItemData]['EN'];
                }
                break;
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: LevelChart(
                    level: 27,
                    levelMax: 100,
                  ),
                ),
                Text(context.loc.quizz_progression_title,
                    style: TextStyle(fontSize: 12, fontFamily: 'roboto')),
                Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Column(
                    children: [
                      CustomTextZillaField(
                        ControlerField: customeTextZillaControllerLearnLocalLanguage,
                        labelText: customeTextZillaControllerLearnLocalLanguage.text == data[randomItemData][LanguageUtils().getSmallCodeLanguage(context: context)]
                            ? "${context.loc.quizz_en} ${context.loc.language_locale}"
                            : "${context.loc.quizz_saisie_in} ${context.loc.language_locale}",
                        resulteField: data[randomItemData][LanguageUtils().getSmallCodeLanguage(context: context)],
                        resultSound: false,
                        voidCallBack: () {
                          viewButtonNext(
                            vocabulaireEnglishLanguage: data[randomItemData]['EN'],
                            vocabulaireLocalLanguage: data[randomItemData][LanguageUtils().getSmallCodeLanguage(context: context)],
                          );
                        },
                      ),
                      CustomTextZillaField(
                        ControlerField: customeTextZillaControllerLearnEnglishLanguage,
                        labelText: customeTextZillaControllerLearnEnglishLanguage.text == data[randomItemData]["EN"]
                            ? "${context.loc.quizz_en} ${context.loc.language_anglais}"
                            : "${context.loc.quizz_saisie_in} ${context.loc.language_anglais}",
                        resulteField: data[randomItemData]['EN'],
                        resultSound: true,
                        GUID: data[randomItemData]['GUID'],
                        voidCallBack: () {
                          viewButtonNext(
                            vocabulaireEnglishLanguage: data[randomItemData]['EN'],
                            vocabulaireLocalLanguage: data[randomItemData][LanguageUtils().getSmallCodeLanguage(context: context)],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: buttonNotifier,
                  builder: (context, child) {
                    return buttonNotifier.showButton
                        ? Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                        onPressed: () {
                           next();
                        },
                        child: Text(context.loc.button_next),
                      ),
                    )
                        : Container();
                  },
                ),
              ],
            ),
          );
        } else if (state is VocabulairesError) {
          return Center(child: Text(context.loc.error_loading));
        } else {
          return Center(child: Text(context.loc.unknown_error)); // fallback
        }
      },
    );
  }


  void next() {
    setState(() {
      refrechRandom = true;
      customeTextZillaControllerLearnLocalLanguage.clear();
      customeTextZillaControllerLearnEnglishLanguage.clear();
    });
  }

  void viewButtonNext({required String vocabulaireLocalLanguage, required String vocabulaireEnglishLanguage}) {
    Future.microtask(() {
      bool shouldShowButton = customeTextZillaControllerLearnLocalLanguage.text == vocabulaireLocalLanguage && customeTextZillaControllerLearnEnglishLanguage.text == vocabulaireEnglishLanguage;
      buttonNotifier.updateButtonState(shouldShowButton);
    });
  }
}

