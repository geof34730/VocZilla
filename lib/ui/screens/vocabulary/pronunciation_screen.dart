import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/core/utils/logger.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'dart:async';

import '../../../core/utils/PlaySoond.dart';
import '../../../core/utils/languageUtils.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';

class PronunciationScreen extends StatefulWidget {
  PronunciationScreen();

  @override
  _PronunciationScreenState createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen> with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  bool isRecording = false;
  late AnimationController _animationController;
  late List<double> _barHeights;
  Timer? _barUpdateTimer;
  bool isCorrect = false;
  late bool refrechRandom = true;
  int randomItemData =0;
  String vocabularyEnSelected = "";
  bool viewResulte = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    Logger.Magenta.log('initState');
    _barHeights = List.generate(10, (index) => 10);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _barUpdateTimer?.cancel();
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
          vocabularyEnSelected= data[randomItemData]['EN'];
        }
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20, width: double.infinity),
               Text(
                context.loc.pronunciation_description_action,
                textAlign: TextAlign.center,
                style: TextStyle(
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
                      spacing: 0,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                      Text(
                        data[randomItemData]['EN'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        "(${data[randomItemData][LanguageUtils().getSmallCodeLanguage(context: context)]})",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                    ]
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10,top:0),
                    child:PlaySoond(
                      guidVocabulaire: data[randomItemData]['GUID'],
                      buttonColor: Colors.green,
                      sizeButton: 20,
                      iconData: Icons.play_arrow,
                      onpressedActionSup: () {
                        setState(() {
                          _stopListening();
                          _stopAnimation();
                          isRecording = false;
                          viewResulte = false;
                        });
                      },
                    ).buttonPlay(),
                  )
                ]
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
                          boxShadow: [
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
                            : Icon(
                          Icons.mic_off,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      Container()
                    ],
                  ),
                ),
              ),

                Column(
                  children: [
                    const SizedBox(height: 20),
                    if(isRecording || viewResulte)...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Icon(Icons.hearing, color: Colors.blueGrey),
                            const SizedBox(width: 8),
                            Text(
                              '${context.loc.pronunciation_i_heard_you_say}:',
                              style: TextStyle(
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
                            color: isRecording ? Colors.black54: isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                    ],
                    const SizedBox(height: 12),
                    if(viewResulte)...[
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
                    ]
                  ],
                )
              ]

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

    /*
    setState(() {
      refrechRandom=true;
      viewResulte=false;
    });
    */

  }


  void _toggleRecording() {

   if(isRecording){
      _stopListening();
      _stopAnimation();
   }
   else {
     _startListening();
     _startAnimation();
   }
    setState(() {
      isRecording = _speechToText.isNotListening;
    });
  }

  void _startAnimation() {
    _animationController.repeat(reverse: true);
    _barUpdateTimer = Timer.periodic(Duration(milliseconds: 200), (_) {
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

  void _checkPermissions() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      _initSpeech();
    } else {
      Logger.Red.log(context.loc.pronunciation_error5);
    }
  }

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize();
      Logger.Yellow.log("_initSpeech: $_speechEnabled");
      if (!_speechEnabled) {
        Logger.Red.log(context.loc.pronunciation_error1);
      }
    } catch (e) {
      Logger.Red.log('${context.loc.pronunciation_error2} : $e');
      _speechEnabled = false;
    }
   // setState(() {});
  }




  void _startListening() async {
    Logger.Yellow.log("_startListening");
    if (_speechEnabled) {
      Logger.Yellow.log("_speechEnabled: $_speechEnabled");
      try {
        await _speechToText.listen(
          onResult: _onSpeechResult,
          listenFor: Duration(seconds: 10), // Set a timeout for listening
          localeId: 'en_US', // Specify the locale if needed
          listenOptions: SpeechListenOptions(
            partialResults: true,
            onDevice: true,
            // Use on-device recognition if available
          )
          // cancelOnError: true, // If deprecated, handle errors manually
        );
        setState(() {
          viewResulte = false;
          isRecording = true;
        });
      } catch (e) {
        Logger.Red.log('${context.loc.pronunciation_error3} : $e');
      }
    } else {
      Logger.Red.log(context.loc.pronunciation_error4);
    }
  }


  void _onSpeechResult(SpeechRecognitionResult result) {
    Logger.Yellow.log('Résultat de la reconnaissance vocale : ${result.recognizedWords} $isRecording ${result.finalResult}');
    setState(() {
      _lastWords = replaceNumbersWithWords(result.recognizedWords);
      if (result.finalResult) {
        isCorrect = _lastWords.toLowerCase() == vocabularyEnSelected.toLowerCase();
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
      // Ajoute plus si nécessaire
    };

    final regex = RegExp(r'\b\d+\b');
    return input.replaceAllMapped(regex, (match) {
      final word = numberWords[match.group(0)];
      return word ?? match.group(0)!; // Laisse tel quel si non trouvé
    });
  }

  void _stopListening() async {
    Logger.Yellow.log("_stopListening");
    await _speechToText.stop();
    setState(() {
      isRecording=false;
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
