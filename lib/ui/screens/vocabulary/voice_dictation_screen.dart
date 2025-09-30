import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/services/admob_service.dart';

import '../../../core/utils/detailTypeVocabulaire.dart';
import '../../../global.dart';
import '../../widget/ads/banner_ad_widget.dart';
import '../../widget/elements/PlaySoond.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';
import '../../../logic/notifiers/button_notifier.dart';
import '../../widget/form/CustomTextZillaField.dart';

class VoiceDictationScreen extends StatefulWidget {
  const VoiceDictationScreen({super.key, required String listName});

  @override
  State<VoiceDictationScreen> createState() => _VoiceDictationScreenState();
}

class _VoiceDictationScreenState extends State<VoiceDictationScreen> {
  late final TextEditingController customeTextZillaControllerDictation =
      TextEditingController();
  late final ButtonNotifier buttonNotifier = ButtonNotifier();

  late double screenWidth;
  int numItemVocabulary = 0;
  late bool refrechRandom = true;
  int randomItemData = 0;
  bool buttonNext = false;
  bool _pageIsLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    // We need to wait for the first frame to have a valid context for ad loading.
    await WidgetsBinding.instance.endOfFrame;

    if (mounted) {
      // Load ads asynchronously to prevent UI freeze.
      await AdMobService.instance.loadDictationScreenBanners(context);
    }

    if (mounted) {
      setState(() {
        _pageIsLoading = false;
      });
    }
  }

  @override
  void dispose() {
    customeTextZillaControllerDictation.dispose();
    buttonNotifier.dispose();
    // Dispose banner ads to free up resources and prevent memory leaks.
    AdMobService.instance.disposeDictationScreenBanners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pageIsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    screenWidth = MediaQuery.of(context).size.width;
    return BlocBuilder<VocabulairesBloc, VocabulairesState>(
      builder: (context, state) {
        if (state is VocabulairesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is VocabulairesLoaded) {
          final List<dynamic> data = state.data.vocabulaireList;
          if (data.isEmpty) {
            return Center(child: Text(context.loc.no_vocabulary_items_found));
          }
          if (refrechRandom || randomItemData >= data.length) {
            refrechRandom = false;
            Random random = Random();
            randomItemData = random.nextInt(data.length);
          }

          return SingleChildScrollView(
            child: Center(
                child: Column(
              key: const ValueKey('screenVoicedictation'),
              children: [
                const AdaptiveBannerAdWidget(
                    placementId: 'dictation_top',
                    padding: EdgeInsets.only(top: 8)),
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
                  buttonNotifier: buttonNotifier,
                  ControlerField: customeTextZillaControllerDictation,
                  labelText: context.loc.dictation_label_text_field,
                  resulteField: data[randomItemData]['EN'],
                  resultSound: false,
                  GUID: data[randomItemData]['GUID'],
                ),
                AnimatedBuilder(
                  animation: buttonNotifier,
                  builder: (context, child) {
                    return (buttonNotifier.showButton || testScreenShot)
                        ? Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  "${data[randomItemData]['EN']} = ${data[randomItemData]['TRAD']} ",
                                  style: const TextStyle(
                                      fontSize: 40.0,
                                      fontWeight: FontWeight.bold,
                                      height: 1),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(
                                "(${getTypeDetaiVocabulaire(typeDetail: data[randomItemData]['TYPE_DETAIL'], context: context)})",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
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
                const AdaptiveBannerAdWidget(
                    placementId: 'dictation_bottom',
                    padding: EdgeInsets.only(top: 8)),
              ],
            )),
          );
        } else if (state is VocabulairesError) {
          return Center(child: Text(context.loc.error_loading));
        } else {
          return Center(
              child: Text(context.loc.unknown_error)); // fallback
        }
      },
    );
  }

  void next() {
    buttonNotifier.updateButtonState(false);
    setState(() {
      refrechRandom = true;
      buttonNext = false;
      customeTextZillaControllerDictation.clear();
    });
  }
}
