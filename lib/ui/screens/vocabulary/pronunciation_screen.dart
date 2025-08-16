import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/core/utils/logger.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'dart:async';

import '../../widget/elements/PlaySoond.dart';
import '../../../core/utils/languageUtils.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';

class PronunciationScreen extends StatefulWidget {
  PronunciationScreen();

  @override
  _PronunciationScreenState createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  bool isRecording = false;

  late AnimationController _animationController;
  late List<double> _barHeights;
  Timer? _barUpdateTimer;

  // NEW: timer pour l’affichage différé de l’erreur
  Timer? _errorDelayTimer;

  bool isCorrect = false;
  late bool refrechRandom = true;
  int randomItemData = 0;
  String vocabularyEnSelected = "";
  bool viewResulte = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    WidgetsBinding.instance.addObserver(this);
    _barHeights = List.generate(10, (index) => 10);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _barUpdateTimer?.cancel();
    _errorDelayTimer?.cancel(); // cleanup
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initSpeech();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabulairesBloc, VocabulairesState>(
      builder: (context, state) {
        if (state is VocabulairesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is VocabulairesLoaded) {
          if (state.data.vocabulaireList.isEmpty) {
            return Center(child: Text(context.loc.no_vocabulary_items_found));
          }
          final List<dynamic> data = state.data.vocabulaireList;
          if (data.isEmpty) {
            return Center(child: Text(context.loc.no_vocabulary_items_found));
          }
          if (refrechRandom) {
            refrechRandom = false;
            Random random = Random();
            randomItemData = random.nextInt(data.length);
            vocabularyEnSelected = data[randomItemData]['EN'];
          }
          return Column(
            key: const ValueKey('screenPrononciation'),
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20, width: double.infinity),
              Text(
                context.loc.pronunciation_description_action,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        data[randomItemData]['EN'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        "(${data[randomItemData][LanguageUtils.getSmallCodeLanguage(context: context)]})",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  // Play désactivé en enregistrement
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 0),
                    child: IgnorePointer(
                      ignoring: isRecording,
                      child: Opacity(
                        opacity: isRecording ? 0.4 : 1.0,
                        child: PlaySoond(
                          guidVocabulaire: data[randomItemData]['GUID'],
                          buttonColor: Colors.green,
                          sizeButton: 20,
                          iconData: Icons.play_arrow,
                        ).buttonPlay(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _toggleRecording,
                child: SizedBox(
                  width: 150,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isRecording) ...[
                        Positioned.fill(
                          child: Center(
                            child: RippleCircle(
                              size: 150 + (_animationController.value * 60),
                              opacity: 1.0 - _animationController.value,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: RippleCircle(
                              size: 130 + (_animationController.value * 50),
                              opacity: 0.7 - (_animationController.value * 0.7),
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: RippleCircle(
                              size: 110 + (_animationController.value * 40),
                              opacity: 0.5 - (_animationController.value * 0.5),
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isRecording ? Colors.red : Colors.green,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: isRecording
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: _barHeights.map((height) {
                            return Container(
                              width: 4,
                              height: height,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              color: Colors.white,
                            );
                          }).toList(),
                        )
                            : const Icon(
                          Icons.mic_off,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      Container(),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 20),
                  if (isRecording || viewResulte) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Icon(Icons.hearing, color: Colors.blueGrey),
                        const SizedBox(width: 8),
                        Text(
                          '${context.loc.pronunciation_i_heard_you_say}:',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastWords,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isRecording ? Colors.black54 : (isCorrect ? Colors.green : Colors.red),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (viewResulte) ...[
                    Text(
                      isCorrect ? '✅ ${context.loc.pronunciation_success}' : '❌ ${context.loc.pronunciation_error}',
                      style: TextStyle(
                        fontSize: isCorrect ? 40 : 20,
                        color: isCorrect ? Colors.green : Colors.red,
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
                ],
              ),
            ],
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
    Navigator.pushReplacementNamed(context, '/vocabulary/pronunciation');
  }

  // Helpers animation
  void _startAnimation() {
    _animationController.repeat(reverse: true);
    _barUpdateTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      setState(() {
        _barHeights = List.generate(10, (index) => Random().nextDouble() * 40 + 10);
      });
    });
  }

  void _stopAnimation() {
    _animationController.stop();
    _animationController.reset();
    _barUpdateTimer?.cancel();
  }

  // NEW: gestion de l’erreur différée
  void _scheduleDeferredErrorDisplay() {
    _errorDelayTimer?.cancel();
    _errorDelayTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      // n’affiche l’erreur que si rien n’a changé: pas d’enregistrement en cours et aucun résultat déjà affiché
      if (!isRecording && !viewResulte) {
        setState(() {
          viewResulte = true;
          isCorrect = false;
        });
      }
    });
  }

  void _cancelDeferredErrorDisplay() {
    _errorDelayTimer?.cancel();
    _errorDelayTimer = null;
  }

  // ---- RESET de l'état d'enregistrement/affichage/anim ----
  void _resetRecordingState() {
    _cancelDeferredErrorDisplay();
    _lastWords = '';
    isCorrect = false;
    viewResulte = false;
    _animationController.reset();
    _barHeights = List.generate(10, (_) => 10);
    setState(() {});
  }

  void _toggleRecording() {
    if (isRecording) {
      _stopListening();
    } else {
      _startListening();
    }
    setState(() {
      isRecording = _speechToText.isListening;
    });
  }

  // ---- INIT avec listeners de statut/erreur ----
  void _onSpeechStatus(String status) {
    Logger.Yellow.log("Speech status: $status");
    _cancelDeferredErrorDisplay(); // tout changement annule l’erreur différée
    if (status == 'notListening') {
      _stopAnimation();
      if (mounted) {
        setState(() {
          isRecording = false;
        });
      }
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    Logger.Red.log("Speech error: ${error.errorMsg} (${error.permanent})");
    _stopAnimation();
    _cancelDeferredErrorDisplay();
    if (mounted) {
      setState(() {
        isRecording = false;
        // NE PAS afficher tout de suite -> on programme l’affichage dans 2s
        // viewResulte reste false pour l’instant
      });
    }
    _scheduleDeferredErrorDisplay();
  }

  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );
      Logger.Yellow.log("_initSpeech: $_speechEnabled");
      if (!_speechEnabled) {
        Logger.Red.log(context.loc.pronunciation_error1);
      }
    } catch (e) {
      Logger.Red.log('${context.loc.pronunciation_error2} : $e');
      _speechEnabled = false;
      // ici, on ne déclenche pas l’affichage d’erreur différé pour ne pas spammer au boot
    }
  }

  void _startListening() async {
    Logger.Yellow.log("_startListening");
    if (_speechEnabled) {
      Logger.Yellow.log("_speechEnabled: $_speechEnabled");
      try {
        await _speechToText.cancel();
        _resetRecordingState();
        _cancelDeferredErrorDisplay();

        await _speechToText.listen(
          onResult: _onSpeechResult,
          listenFor: const Duration(seconds: 3),
          localeId: 'en_US',
          listenOptions: SpeechListenOptions(
            partialResults: true,
            onDevice: true,
          ),
        );

        setState(() {
          viewResulte = false;
          isRecording = true;
        });
        _startAnimation();
      } catch (e) {
        Logger.Red.log('${context.loc.pronunciation_error3} : $e');
        _stopAnimation();
        setState(() {
          isRecording = false;
          // pas d’affichage immédiat de l’erreur
        });
        _scheduleDeferredErrorDisplay();
      }
    } else {
      Logger.Red.log(context.loc.pronunciation_error4);
      // si on n’est pas prêt à écouter, on propose l’erreur après 2s
      _scheduleDeferredErrorDisplay();
    }
  }

  // ✅ Succès immédiat si le partiel matche, sinon on attend la fin
  void _onSpeechResult(SpeechRecognitionResult result) {
    _cancelDeferredErrorDisplay(); // un résultat est arrivé, donc l’erreur différée n’est plus pertinente

    final normalized = replaceNumbersWithWords(result.recognizedWords);
    final nowCorrect = normalized.toLowerCase().trim() == vocabularyEnSelected.toLowerCase().trim();

    setState(() {
      _lastWords = normalized;

      // debug
      // ignore: avoid_print
      print("***************** $_lastWords");
      // ignore: avoid_print
      print("***************** *${_lastWords.toLowerCase()}* == *${vocabularyEnSelected.toLowerCase()}* ");

      if (nowCorrect) {
        isCorrect = true;
        _stopListening();   // stop micro
        _stopAnimation();   // stop anim
        isRecording = false;
        viewResulte = true; // ✅ immédiat
      } else if (result.finalResult) {
        // Fin d’écoute et ce n’est pas correct -> affiche ❌
        isCorrect = false;
        _stopListening();
        _stopAnimation();
        isRecording = false;
        viewResulte = true;
      }
    });
  }

  String replaceNumbersWithWords(String input) {
    final Map<String, String> numberWords = {
      '0': 'zero',
      '1': 'one',
      '2': 'two',
      '3': 'three',
      '4': 'four',
      '5': 'five',
      '6': 'six',
      '7': 'seven',
      '8': 'eight',
      '9': 'nine',
      '10': 'ten',
      '11': 'eleven',
      '12': 'twelve',
      '13': 'thirteen',
      '14': 'fourteen',
      '15': 'fifteen',
      '16': 'sixteen',
      '17': 'seventeen',
      '18': 'eighteen',
      '19': 'nineteen',
      '20': 'twenty',
      '25': 'twenty-five',
      '30': 'thirty',
      '50': 'fifty',
      '100': 'one hundred',
    };

    final regex = RegExp(r'\b\d+\b');
    return input.replaceAllMapped(regex, (match) {
      final word = numberWords[match.group(0)];
      return word ?? match.group(0)!;
    });
  }

  void _stopListening() async {
    Logger.Yellow.log("_stopListening");
    try {
      await _speechToText.stop();
    } catch (_) {}
    _stopAnimation();
    _cancelDeferredErrorDisplay(); // un stop manuel annule l’erreur différée
    setState(() {
      isRecording = false;
    });
  }
}

class RippleCircle extends StatelessWidget {
  final double size;
  final double opacity;
  final Color color;

  const RippleCircle({
    Key? key,
    required this.size,
    required this.opacity,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color,
            width: 2,
          ),
        ),
      ),
    );
  }
}
