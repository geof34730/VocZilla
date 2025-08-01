import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';

import '../../widget/elements/PlaySoond.dart';
import '../../../core/utils/languageUtils.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';
import '../../../logic/notifiers/button_notifier.dart';
import '../../widget/form/CustomTextZillaField.dart';

class VoiceDictationScreen extends StatefulWidget {
  VoiceDictationScreen();

  @override
  _VoiceDictationScreenState createState() => _VoiceDictationScreenState();
}

class _VoiceDictationScreenState extends State<VoiceDictationScreen> {
  late TextEditingController customeTextZillaControllerDictation = TextEditingController();
  late ButtonNotifier buttonNotifier = ButtonNotifier();

  late double screenWidth;
  int numItemVocabulary = 0;
  late bool refrechRandom = true;
  int randomItemData =0;
  bool buttonNext = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    customeTextZillaControllerDictation.dispose();
    buttonNotifier.dispose();
    buttonNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return BlocBuilder<VocabulairesBloc, VocabulairesState>(
      builder: (context, state) {
        if (state is VocabulairesLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is VocabulairesLoaded) {
          final List<dynamic> data = state.data.vocabulaireList;
          if (data.isEmpty) {
            return Center(child: Text(context.loc.no_vocabulary_items_found));
          }
          if(refrechRandom){
            refrechRandom=false;
            Random random = new Random();
            randomItemData = random.nextInt(data.length);
          }

      return SingleChildScrollView(
        child: Center(
            child: Column(
              key: ValueKey('screenVoicedictation'),
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: PlaySoond(
                          guidVocabulaire: data[randomItemData]['GUID'],
                          sizeButton: 100,
                          buttonColor: Colors.green,
                          iconData: Icons.play_arrow)
                      .buttonPlay(),
                ),
                CustomTextZillaField(
                  ButtonNextNotifier: true,
                  buttonNotifier:buttonNotifier,
                  ControlerField: customeTextZillaControllerDictation,
                  labelText: context.loc.dictation_label_text_field,
                  resulteField: data[randomItemData]['EN'],
                  resultSound: false,
                  GUID: data[randomItemData]['GUID'],
                ),
                AnimatedBuilder(
                  animation: buttonNotifier,
                  builder: (context, child) {
                    return buttonNotifier.showButton
                        ?
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text(
                                "${data[randomItemData]['EN']} = ${data[randomItemData][LanguageUtils.getSmallCodeLanguage(context: context)]}",
                                style: TextStyle(
                                  fontSize: 40.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  next();
                                },
                                child: Text(context.loc.button_next),
                              ),
                            ),
                          ],
                        )
                        : Container();
                  },
                ),
              ],
            )),
          );
        } else if (state is VocabulairesError) {
          return Center(child: Text(context.loc.error_loading));
        } else {
          return Center(child: Text(context.loc.unknown_error)); // fallback
        }
      },
    );
  }

  next() {
    buttonNotifier.updateButtonState(false);
    setState(() {
      refrechRandom=true;
      buttonNext = false;
      customeTextZillaControllerDictation.clear();
    });
  }
}
