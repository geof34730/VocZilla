import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';

import '../../../core/utils/languageUtils.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';
import '../../widget/elements/LevelChart.dart';
import '../../widget/form/CustomTextZillaField.dart';

class QuizzScreen extends StatefulWidget {
  QuizzScreen();

  @override
  _QuizzScreenState createState() => _QuizzScreenState();
}

class _QuizzScreenState extends State<QuizzScreen> {
  late TextEditingController customeTextZillaControllerLearnLocalLanguage = TextEditingController();
  late TextEditingController customeTextZillaControllerLearnEnglishLanguage = TextEditingController();

  late bool refrechRandom = true;
  int randomItemData = 0;
  bool buttonNext = false;

  @override
  Widget build(BuildContext context) {
    var currentLocale = BlocProvider.of<LocalizationCubit>(context).state;
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
              Text("Ma progression dan cette liste",
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'roboto'
                  )
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                  child:Column(
                      children: [
                        CustomTextZillaField(
                        ControlerField: customeTextZillaControllerLearnLocalLanguage,
                        labelText: "Saisissez la traduction en français",
                        hintText: "En français",
                        resulteField: data[randomItemData]['FR'],
                        resultSound: false,
                        voidCallBack: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              buttonNext = true;
                            });
                          });
                        },
                      ),
                      CustomTextZillaField(
                        ControlerField: customeTextZillaControllerLearnEnglishLanguage,
                        labelText: "Saisissez la traduction en anglais",
                        hintText: "En anglais",
                        resulteField: data[randomItemData]['EN'],
                        resultSound: false,
                        voidCallBack: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              buttonNext = true;
                            });
                          });
                        },
                      ),
                    ],
              )
          ),
              if (buttonNext)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      // next();
                    },
                    child: Text(context.loc.button_next),
                  ),
                ),
            ],
          ));
        } else if (state is VocabulairesError) {
          return Center(child: Text(context.loc.error_loading));
        } else {
          return Center(child: Text(context.loc.unknown_error)); // fallback
        }
      },
    );
  }
}
