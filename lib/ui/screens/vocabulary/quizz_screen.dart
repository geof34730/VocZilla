// lib/ui/screens/vocabulary/quizz_screen.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/ui/widget/form/RadioChoiceVocabularyLearnedOrNot.dart';
import '../../../core/utils/detailTypeVocabulaire.dart';
import '../../../core/utils/languageUtils.dart';
import '../../../data/repository/vocabulaire_repository.dart';
import '../../../global.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';

import '../../widget/form/CongratulationOrErrorData.dart';
import '../../widget/form/CustomTextZillaField.dart';
import '../../../logic/notifiers/button_notifier.dart';
import '../../widget/statistical/global_statisctical_widget.dart'; // Importez ici

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
  final _vocabulaireRepository=VocabulaireRepository();
  @override
  void dispose() {
    customeTextZillaControllerLearnLocalLanguage.dispose();
    customeTextZillaControllerLearnEnglishLanguage.dispose();
    buttonNotifier.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Center(
        child:Column(

      children: [
        BlocBuilder<VocabulairesBloc, VocabulairesState>(
        builder: (context, state) {
          if (state is VocabulairesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is VocabulairesLoaded) {
            final List<dynamic> data = state.data.vocabulaireList;
            bool isNotLearned = state.data.isVocabularyNotLearned ?? true;
            int _vocabulaireConnu = isNotLearned ? 0 : 1;
            if (refrechRandom) {
              refrechRandom = false;
              if (data.isNotEmpty) {
                Random random = new Random();
                randomItemData = random.nextInt(data.length);
                switch (Random().nextInt(2)) {
                  case 0:
                    {
                      customeTextZillaControllerLearnLocalLanguage.text =data[randomItemData]["TRAD"];
                    }
                    break;
                  case 1:
                    {
                      customeTextZillaControllerLearnEnglishLanguage.text = data[randomItemData]['EN'];
                    }
                    break;
                }
              }
            }
            return Column(
              key: ValueKey('screenQuizz'),
              children: [
                state.data.isListPerso || state.data.isListTheme
                ?
                  GlobalStatisticalWidget(
                    guidList: state.data.guid,
                    isListPerso : state.data.isListPerso,
                    isListTheme : state.data.isListTheme,
                    local: LanguageUtils.getSmallCodeLanguage(context: context)
                  )
                :
                  GlobalStatisticalWidget(
                    vocabulaireBegin: state.data.vocabulaireBegin,
                    vocabulaireEnd: state.data.vocabulaireEnd,
                    isListPerso : false,
                    isListTheme : false,
                    local:LanguageUtils.getSmallCodeLanguage(context: context)
                  ),

                Text(context.loc.quizz_progression_title,
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'roboto'
                    )
                ),
                RadioChoiceVocabularyLearnedOrNot(
                  state: state,
                  vocabulaireConnu: _vocabulaireConnu,
                  vocabulaireRepository: _vocabulaireRepository,
                  local: LanguageUtils.getSmallCodeLanguage(context: context),
                ),
                  if (data.isEmpty)...[
                    CongratulationOrErrorData(vocabulaireConnu:_vocabulaireConnu,context: context)
                  ],
                  if (data.isNotEmpty)...[
                       SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 0, bottom: 20),
                              child: Column(
                                children: [
                                  CustomTextZillaField(
                                    AnswerNotifier: true,
                                    ButtonNextNotifier: true,
                                    buttonNotifier: buttonNotifier,
                                    ControlerField: customeTextZillaControllerLearnLocalLanguage,
                                    labelText: customeTextZillaControllerLearnLocalLanguage.text.isNotEmpty
                                        ? "${context.loc.quizz_en} ${context.loc
                                        .language_locale}"
                                        : "${context.loc.quizz_saisie_in} ${context
                                        .loc.language_locale}",
                                    resulteField: data[randomItemData]["TRAD"],
                                    resultSound: false,
                                    GUID: data[randomItemData]['GUID'],
                                  ),

                                  CustomTextZillaField(
                                    AnswerNotifier: true,
                                    ButtonNextNotifier: true,
                                    buttonNotifier: buttonNotifier,
                                    ControlerField: customeTextZillaControllerLearnEnglishLanguage,
                                    labelText: customeTextZillaControllerLearnEnglishLanguage.text.isNotEmpty
                                        ? "${context.loc.quizz_en} ${context.loc
                                        .language_anglais}"
                                        : "${context.loc.quizz_saisie_in} ${context
                                        .loc.language_anglais}",
                                    resulteField: data[randomItemData]['EN'],
                                    resultSound: true,
                                    GUID: data[randomItemData]['GUID'],
                                  ),
                                  Text(
                                    "(${getTypeDetaiVocabulaire(typeDetail:data[randomItemData]['TYPE_DETAIL'],context: context)})",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        height:1
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedBuilder(
                              animation: buttonNotifier,
                              builder: (context, child) {
                                return (buttonNotifier.showButton || testScreenShot)
                                    ? Padding(
                                  padding: const EdgeInsets.only(top: 0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _vocabulaireRepository.goVocabulairesWithState(
                                          context: context,
                                          isVocabularyNotLearned: _vocabulaireConnu==0 ? true : false,
                                          state: state,
                                          local: LanguageUtils.getSmallCodeLanguage(context: context)
                                      );
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
                      )
                ]
             ],
           );
          } else if (state is VocabulairesError) {
            return Center(child: Text(context.loc.error_loading));
          } else {
            return Center(child: Text(context.loc.unknown_error)); // fallback
          }
        },
      )
      ],
        )
    );
  }


  void next() {
    buttonNotifier.updateButtonState(false);
    reset();
  }

  void reset(){
    setState(() {
      refrechRandom = true;
      customeTextZillaControllerLearnLocalLanguage.clear();
      customeTextZillaControllerLearnEnglishLanguage.clear();
    });
  }




}
