// lib/ui/screens/vocabulary/quizz_screen.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/core/utils/localization.dart';
import '../../../core/utils/languageUtils.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
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
  int? _vocabulaireConnu=0;
  @override
  void dispose() {
    customeTextZillaControllerLearnLocalLanguage.dispose();
    customeTextZillaControllerLearnEnglishLanguage.dispose();
    buttonNotifier.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<VocabulairesBloc, VocabulairesState>(
        builder: (context, state) {
          if (state is VocabulairesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is VocabulairesLoaded) {
            if (state.data.isEmpty) {
              return Center(child: Text(context.loc.no_vocabulary_items_found));
            }
            final List<dynamic> dataStatetisctical = state.data["vocabulaireList"] as List<dynamic>;
            return Column(
              children: [
                GlobalStatisticalWidget(userDataSpecificList: dataStatetisctical),
                Text(context.loc.quizz_progression_title,
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'roboto'
                    )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        _vocabulaireConnu = 0;
                        reset();
                      },
                      child: Row(
                        children: [
                          Radio<int>(
                            value: 0,
                            groupValue: _vocabulaireConnu,
                            onChanged: (int? value) {
                              setState(() {
                                _vocabulaireConnu = value;
                              });
                            },
                          ),
                          Text("vocabulaire encore à apprendre"),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        _vocabulaireConnu = 1;
                        reset();
                      },
                      child: Row(
                        children: [
                          Radio<int>(
                            value: 1,
                            groupValue: _vocabulaireConnu,
                            onChanged: (int? value) {
                              print(value);
                              setState(() {
                                _vocabulaireConnu = value;
                              });
                            },
                          ),
                          Text("tous les vocabulaires"),
                        ],
                      ),
                    ),
                  ],
                ),
                FutureBuilder(
                    future: (_vocabulaireConnu == 0
                        ? VocabulaireUserRepository(context: context).getDataNotLearned(
                        vocabulaireSpecificList: state.data["vocabulaireList"] as List<dynamic>)
                        : getFutureData(state.data["vocabulaireList"] as List<dynamic>)
                    ),
                  builder: (context, userDataSnapshot) {
                    if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Show a loading indicator while waiting
                    } else if (userDataSnapshot.hasError) {
                      return Text('Erreur affichage Statistique'); // Handle error
                    } else if (userDataSnapshot.hasData) {
                      final data = userDataSnapshot.data;
                      if (data!.isEmpty) {
                        return _vocabulaireConnu==0 ?
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
                          : Center(
                              child: Text(context.loc.no_vocabulary_items_found)
                          );
                      }
                      if (refrechRandom) {
                        refrechRandom = false;
                        Random random = new Random();
                        randomItemData = random.nextInt(data.length);
                        switch (Random().nextInt(2)) {
                          case 0:
                            {
                              customeTextZillaControllerLearnLocalLanguage.text =
                              data[randomItemData][LanguageUtils()
                                  .getSmallCodeLanguage(context: context)];
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
                      return SingleChildScrollView(
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
                  }
               )
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

  Future<dynamic> getFutureData(dynamic data) async {
    return data;
  }



}

