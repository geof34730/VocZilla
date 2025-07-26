// lib/ui/screens/vocabulary/voice_dictation_screen.dart

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vobzilla/core/utils/languageUtils.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/core/utils/logger.dart';
import 'package:vobzilla/logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import 'package:vobzilla/logic/blocs/vocabulaires/vocabulaires_state.dart';

import '../../widget/elements/PlaySoond.dart';

// Fonction utilitaire déplacée en dehors de la classe pour une meilleure organisation.
String _replaceNumbersWithWords(String input) {
  const Map<String, String> numberWords = {
    '0': 'zero', '1': 'one', '2': 'two', '3': 'three', '4': 'four',
    '5': 'five', '6': 'six', '7': 'seven', '8': 'eight', '9': 'nine',
    '10': 'ten', '11': 'eleven', '12': 'twelve', '13': 'thirteen',
    '14': 'fourteen', '15': 'fifteen', '16': 'sixteen', '17': 'seventeen',
    '18': 'eighteen', '19': 'nineteen', '20': 'twenty', '25': 'twenty-five',
    '30': 'thirty', '50': 'fifty', '100': 'one hundred',
  };

  final regex = RegExp(r'\b\d+\b');
  return input.replaceAllMapped(regex, (match) {
    final word = numberWords[match.group(0)];
    return word ?? match.group(0)!;
  });
}

class VoiceDictationScreen extends StatefulWidget {
  const VoiceDictationScreen({super.key});

  @override
  State<VoiceDictationScreen> createState() => _VoiceDictationScreenState();
}

class _VoiceDictationScreenState extends State<VoiceDictationScreen>
    with SingleTickerProviderStateMixin {
  // Dépendances et Contrôleurs
  final SpeechToText _speechToText = SpeechToText();
  late final AnimationController _animationController;
  Timer? _barUpdateTimer;

  // Variables d'état pour la logique et l'UI
  bool _speechEnabled = false;
  String _lastWords = '';
  bool _isRecording = false;
  bool _isCorrect = false;
  bool _showResult = false;
  List<double> _barHeights = List.generate(10, (index) => 10.0);

  // Variables d'état pour les données de vocabulaire
  List<dynamic> _vocabularyList = [];
  int? _currentWordIndex;
  String _currentEnglishWord = "";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    // On initialise directement le module de reconnaissance vocale.
    _initSpeech();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _barUpdateTimer?.cancel();
    // Il est bon de s'assurer que le plugin est arrêté et annulé.
    _speechToText.cancel();
    super.dispose();
  }

  /// Sélectionne un nouveau mot au hasard et réinitialise l'état de l'interface.
  void _pickNewWord() {
    if (_vocabularyList.isEmpty) return;
    final random = Random();
    setState(() {
      _currentWordIndex = random.nextInt(_vocabularyList.length);
      _currentEnglishWord = _vocabularyList[_currentWordIndex!]['EN'];
      _lastWords = '';
      _isCorrect = false;
      _showResult = false;
    });
  }

  /// Annule un enregistrement en cours sans évaluer le résultat.
  void _cancelRecording() {
    // On vérifie l'état réel du plugin
    if (!_speechToText.isListening) return;

    // On peut réinitialiser les mots immédiatement pour une meilleure réactivité visuelle.
    if (mounted) {
      setState(() {
        _lastWords = '';
        _showResult = false;
      });
    }
    // cancel() arrête l'écoute SANS envoyer de résultat final.
    // Le `statusListener` se chargera de mettre à jour _isRecording et d'arrêter l'animation.
    _speechToText.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VocabulairesBloc, VocabulairesState>(
      listener: (context, state) {
        if (state is VocabulairesLoaded && state.data.vocabulaireList.isNotEmpty) {
          _vocabularyList = state.data.vocabulaireList;
          if (_currentWordIndex == null) {
            _pickNewWord();
          }
        }
      },
      builder: (context, state) {
        if (state is VocabulairesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is VocabulairesLoaded) {
          if (_vocabularyList.isEmpty || _currentWordIndex == null) {
            return Center(child: Text(context.loc.no_vocabulary_items_found));
          }
          return _buildContent();
        }

        if (state is VocabulairesError) {
          return Center(child: Text(context.loc.error_loading));
        }

        return Center(child: Text(context.loc.unknown_error));
      },
    );
  }

  /// Construit le contenu principal de l'écran.
  Widget _buildContent() {
    final currentWord = _vocabularyList[_currentWordIndex!];
    return Column(
      key: const ValueKey('screenPrononciation'),
      mainAxisAlignment: MainAxisAlignment.center,
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
        _buildWordDisplay(currentWord),
        const SizedBox(height: 20),
        _buildMicButton(),
        _buildResultDisplay(),
      ],
    );
  }

  /// Affiche le mot à prononcer et sa traduction.
  Widget _buildWordDisplay(dynamic wordData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(
              wordData['EN'],
              style: const TextStyle(
                fontSize: 40,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
            Text(
              "(${wordData[LanguageUtils.getSmallCodeLanguage(context: context)]})",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                height: 1.2,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: PlaySoond(
            guidVocabulaire: wordData['GUID'],
            buttonColor: Colors.green,
            sizeButton: 20,
            iconData: Icons.play_arrow,
            onpressedActionSup: _cancelRecording,
          ).buttonPlay(),
        ),
      ],
    );
  }

  /// Construit le bouton du microphone avec son animation.
  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _toggleRecording,
      child: SizedBox(
        width: 150,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isRecording)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      RippleCircle(
                        size: 150 + (_animationController.value * 60),
                        opacity: 1.0 - _animationController.value,
                        color: Colors.redAccent,
                      ),
                      RippleCircle(
                        size: 130 + (_animationController.value * 50),
                        opacity: 0.7 - (_animationController.value * 0.7),
                        color: Colors.redAccent,
                      ),
                      RippleCircle(
                        size: 110 + (_animationController.value * 40),
                        opacity: 0.5 - (_animationController.value * 0.5),
                        color: Colors.redAccent,
                      ),
                    ],
                  );
                },
              ),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording ? Colors.red : Colors.green,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: _isRecording
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _barHeights.map((height) {
                  return Container(
                    width: 4,
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    color: Colors.white,
                  );
                }).toList(),
              )
                  : const Icon(Icons.mic, size: 60, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// Affiche le résultat de la prononciation.
  Widget _buildResultDisplay() {
    if (!_isRecording && !_showResult) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
            color: _isRecording
                ? Colors.black54
                : _isCorrect
                ? Colors.green
                : Colors.red,
          ),
        ),
        const SizedBox(height: 12),
        if (_showResult) ...[
          Text(
            _isCorrect
                ? '✅ ${context.loc.pronunciation_success}'
                : '❌ ${context.loc.pronunciation_error}',
            style: TextStyle(
              fontSize: _isCorrect ? 40 : 20,
              color: _isCorrect ? Colors.green : Colors.red,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
              onPressed: _pickNewWord,
              child: Text(context.loc.button_next),
            ),
          ),
        ]
      ],
    );
  }

  // --- Logique pour la reconnaissance vocale et l'animation ---

  void _toggleRecording() {
    if (_isRecording) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startAnimation() {
    _animationController.repeat(reverse: true);
    _barUpdateTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      setState(() {
        _barHeights =
            List.generate(10, (index) => Random().nextDouble() * 40 + 10);
      });
    });
  }

  void _stopAnimation() {
    _animationController.stop();
    _animationController.reset();
    _barUpdateTimer?.cancel();
  }

  Future<bool> _checkPermissions() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      Logger.Red.log(context.loc.pronunciation_error5);
    }
    return status.isGranted;
  }

  void _initSpeech() async {
    bool hasPermission = await _checkPermissions();
    if (!mounted || !hasPermission) return;

    try {
      // On initialise le plugin avec des callbacks pour le statut et les erreurs.
      _speechEnabled = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );
      if (!mounted) return;

      if (!_speechEnabled) {
        Logger.Red.log(context.loc.pronunciation_error1);
      }
    } catch (e) {
      if (mounted) {
        Logger.Red.log('${context.loc.pronunciation_error2} : $e');
        _speechEnabled = false;
      }
    }
  }

  /// Callback principal qui met à jour l'état de l'UI en fonction du statut du plugin.
  void _onSpeechStatus(String status) {
    if (!mounted) return;
    Logger.Yellow.log('Speech status: $status');

    final isCurrentlyListening = _speechToText.isListening;
    // On met à jour l'état et l'animation seulement si l'état a réellement changé.
    if (_isRecording != isCurrentlyListening) {
      setState(() {
        _isRecording = isCurrentlyListening;
      });
      if (isCurrentlyListening) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  /// Callback pour gérer les erreurs du plugin.
  void _onSpeechError(SpeechRecognitionError error) {
    if (!mounted) return;
    Logger.Red.log('Speech error: ${error.errorMsg}');

    // On s'assure que tout est bien arrêté et réinitialisé en cas d'erreur.
    _stopAnimation();
    setState(() {
      _lastWords = "Error: ${error.errorMsg}";
      _isRecording = false;
      _showResult = false;
    });
  }

  void _startListening() async {
    if (!_speechEnabled) {
      if (!mounted) return;
      Logger.Red.log(context.loc.pronunciation_error4);
      return;
    }

    try {
      // On réinitialise l'état des résultats avant de commencer.
      setState(() {
        _lastWords = '';
        _showResult = false;
      });

      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 10),
        localeId: 'en_US',
        listenOptions:  SpeechListenOptions(
          partialResults: true,
          onDevice: true,
        ),
      );
      // Le `statusListener` mettra à jour `_isRecording` et démarrera l'animation.
    } catch (e) {
      if (!mounted) return;
      Logger.Red.log('${context.loc.pronunciation_error3} : $e');
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;

    setState(() {
      _lastWords = _replaceNumbersWithWords(result.recognizedWords);
    });

    if (result.finalResult) {
      // Le statusListener s'occupera d'arrêter l'animation et de mettre _isRecording à false.
      // On se contente de gérer la logique du résultat.
      setState(() {
        _isCorrect = _lastWords.toLowerCase() == _currentEnglishWord.toLowerCase();
        _showResult = true;
      });
    }
  }

  void _stopListening() async {
    // On demande juste au plugin de s'arrêter.
    // Le statusListener s'occupera de la mise à jour de l'état.
    _speechToText.stop();
  }
}

/// Widget pour l'animation d'ondulation.
class RippleCircle extends StatelessWidget {
  final double size;
  final double opacity;
  final Color color;

  const RippleCircle({
    super.key,
    required this.size,
    required this.opacity,
    required this.color,
  });

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
