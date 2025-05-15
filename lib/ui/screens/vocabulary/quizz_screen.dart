// lib/ui/screens/vocabulary/quizz_screen.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/ui/widget/form/RadioChoiceVocabularyLearnedOrNot.dart';
import '../../../core/utils/languageUtils.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
import '../../../data/repository/vocabulaires_repository.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';
import '../../../logic/notifiers/answer_notifier.dart';
import '../../widget/elements/LevelChart.dart';
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
  @override
  void dispose() {
    customeTextZillaControllerLearnLocalLanguage.dispose();
    customeTextZillaControllerLearnEnglishLanguage.dispose();
    buttonNotifier.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final _vocabulairesRepository=VocabulairesRepository(context:context);
    return Column(
      children: [
        BlocBuilder<VocabulairesBloc, VocabulairesState>(
        builder: (context, state) {
          if (state is VocabulairesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is VocabulairesLoaded) {
            if (state.data.vocabulaireList.isEmpty) {
              return Center(child: Text(context.loc.no_vocabulary_items_found));
            }
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
                      customeTextZillaControllerLearnLocalLanguage.text =
                      data[randomItemData][LanguageUtils().getSmallCodeLanguage(
                          context: context)];
                    }
                    break;
                  case 1:
                    {
                      customeTextZillaControllerLearnEnglishLanguage.text =
                      data[randomItemData]['EN'];
                    }
                    break;
                }
              }
            }
            return Column(
              children: [
                GlobalStatisticalWidget(
                  vocabulaireBegin: state.data.vocabulaireBegin,
                  vocabulaireEnd: state.data.vocabulaireEnd,
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
                  vocabulairesRepository: _vocabulairesRepository,

                ),
                if (data.isEmpty)...[
                  _vocabulaireConnu==0 ?
                  Column(
                      children: [
                        Padding(
                            padding:EdgeInsets.only(top: 40),
                            child:Text("✅ Bravo !!!",
                              style: TextStyle(
                                  color:Colors.green,
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold
                              ),
                            )
                        ),
                        Text("vous avez terminé d'apprendre cette Liste",
                          style: TextStyle(
                            color:Colors.green,
                            fontSize: 20,

                          ),

                        )
                      ]
                  )
                      : Center(child: Text(context.loc.no_vocabulary_items_found)
                  )
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
                                    labelText: customeTextZillaControllerLearnLocalLanguage
                                        .text == data[randomItemData][LanguageUtils()
                                        .getSmallCodeLanguage(context: context)]
                                        ? "${context.loc.quizz_en} ${context.loc
                                        .language_locale}"
                                        : "${context.loc.quizz_saisie_in} ${context
                                        .loc.language_locale}",
                                    resulteField: data[randomItemData][LanguageUtils()
                                        .getSmallCodeLanguage(context: context)],
                                    resultSound: false,
                                    GUID: data[randomItemData]['GUID'],
                                  ),
                                  CustomTextZillaField(
                                    AnswerNotifier: true,
                                    ButtonNextNotifier: true,
                                    buttonNotifier: buttonNotifier,
                                    ControlerField: customeTextZillaControllerLearnEnglishLanguage,
                                    labelText: customeTextZillaControllerLearnEnglishLanguage
                                        .text == data[randomItemData]["EN"]
                                        ? "${context.loc.quizz_en} ${context.loc
                                        .language_anglais}"
                                        : "${context.loc.quizz_saisie_in} ${context
                                        .loc.language_anglais}",
                                    resulteField: data[randomItemData]['EN'],
                                    resultSound: true,
                                    GUID: data[randomItemData]['GUID'],
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
                                      _vocabulairesRepository.goVocabulairesTop(
                                          vocabulaireBegin:  state.data.vocabulaireBegin,
                                          vocabulaireEnd: state.data.vocabulaireEnd,
                                          titleList: state.data.titleList,
                                          isVocabularyNotLearned:_vocabulaireConnu==0 ? true : false,
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

