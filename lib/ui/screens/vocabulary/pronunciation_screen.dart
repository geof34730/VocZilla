import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // rootBundle
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart'; // v6.x -> AudioRecorder
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart'; // v1.12.9

import '../../../global.dart';
import '../../widget/elements/PlaySoond.dart';
import '../../../core/utils/languageUtils.dart';
import '../../../core/utils/localization.dart';
import '../../../core/utils/logger.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';

class PronunciationScreen extends StatefulWidget {
  PronunciationScreen();

  @override
  _PronunciationScreenState createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // ===== Sherpa-ONNX (v1.12.9) =====
  OnlineRecognizer? _recognizer;
  OnlineStream? _asrStream;

  // Micro (record v6)
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _micSub;
  static const int _sampleRate = 16000; // 16 kHz

  // ===== UI/état =====
  String _lastWords = '';
  bool isRecording = false;
  late AnimationController _animationController;
  late List<double> _barHeights;
  Timer? _barUpdateTimer;

  // affichage différé erreur
  Timer? _errorDelayTimer;

  bool isCorrect = false;
  late bool refrechRandom = true;
  int randomItemData = 0;
  String vocabularyEnSelected = "";
  bool viewResulte = false;

  // silence detection
  DateTime? _lastAudioTs;

  // permission micro (one-shot)
  bool _micReady = false;

  // état d’initialisation
  bool _initInProgress = true; // on démarre en “initialisation en cours”
  bool _asrReady = false;      // ASR prêt (recognizer créé) ?

  // Assets (clé bundle)
  static const String _pTokens  = 'assets/asr_en/tokens.txt';
  static const String _pEncoder = 'assets/asr_en/encoder-epoch-99-avg-1.int8.onnx';
  static const String _pDecoder = 'assets/asr_en/decoder-epoch-99-avg-1.int8.onnx';
  static const String _pJoiner  = 'assets/asr_en/joiner-epoch-99-avg-1.int8.onnx';

  // FICHIERS LOCAUX (chemins absolus pour Sherpa)
  String? _fTokens, _fEncoder, _fDecoder, _fJoiner;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _barHeights = List.generate(10, (index) => 10);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Bootstrap: permission + assets + init sherpa
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _bootstrapAsr();
    });
  }

  Future<void> _bootstrapAsr() async {
    setState(() {
      _initInProgress = true;
      _asrReady = false;
    });

    if (!(await _ensureMic())) {
      Logger.Red.log("Microphone permission denied");
      setState(() {
        _initInProgress = false; // on arrête l’init (bouton restera grisé)
      });
      return;
    }

    final ok = await _assertAssetsPresent();
    if (!ok) {
      setState(() => _initInProgress = false);
      return;
    }

    await _initSherpaOnnx();

    setState(() {
      _asrReady = _recognizer != null;
      _initInProgress = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _micSub?.cancel();
    _recorder.dispose();

    _asrStream?.free();
    _recognizer?.free();

    _animationController.dispose();
    _barUpdateTimer?.cancel();
    _errorDelayTimer?.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopListening();
    }
  }

  // ===== Permissions (one-shot) =====
  Future<bool> _ensureMic() async {
    if (_micReady) return true;
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    _micReady = status.isGranted;
    return _micReady;
  }

  // ===== Vérifier assets (bundle) =====
  Future<bool> _assertAssetsPresent() async {
    Future<bool> _probe(String p) async {
      try {
        await rootBundle.load(p);
        Logger.Green.log("ASR asset OK: $p");
        return true;
      } catch (e) {
        Logger.Red.log("ASR asset manquant: $p -> $e");
        return false;
      }
    }

    final okTokens  = await _probe(_pTokens);
    final okEncoder = await _probe(_pEncoder);
    final okDecoder = await _probe(_pDecoder);
    final okJoiner  = await _probe(_pJoiner);

    final ok = okTokens && okEncoder && okDecoder && okJoiner;
    if (!ok) {
      Logger.Red.log("Assets ASR incomplets. Vérifie pubspec.yaml et assets/asr_en/");
      _scheduleDeferredErrorDisplay();
    }
    return ok;
  }

  // ===== Copie des assets → fichiers locaux =====
  Future<String> _copyAssetToFile(String assetKey, String relativeName) async {
    final data = await rootBundle.load(assetKey);
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/$relativeName');
    await file.create(recursive: true);
    await file.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );
    Logger.Green.log('ASR file ready: ${file.path}');
    return file.path;
  }

  Future<void> _materializeAsrAssets() async {
    _fTokens  = await _copyAssetToFile(_pTokens,  'asr_en/tokens.txt');
    _fEncoder = await _copyAssetToFile(_pEncoder, 'asr_en/encoder.onnx');
    _fDecoder = await _copyAssetToFile(_pDecoder, 'asr_en/decoder.onnx');
    _fJoiner  = await _copyAssetToFile(_pJoiner,  'asr_en/joiner.onnx');
  }

  // ===== Init Sherpa-ONNX (API 1.12.9) =====
  Future<void> _initSherpaOnnx() async {
    try {
      await _materializeAsrAssets();
      initBindings(); // obligatoire

      final model = OnlineModelConfig(
        tokens: _fTokens!,
        numThreads: 2,
        provider: 'cpu',
        debug: false,
        transducer: OnlineTransducerModelConfig(
          encoder: _fEncoder!,
          decoder: _fDecoder!,
          joiner:  _fJoiner!,
        ),
      );

      _recognizer = OnlineRecognizer(OnlineRecognizerConfig(
        model: model,
        decodingMethod: 'greedy_search',
        enableEndpoint: true, // pas de rule1/2/3 dans 1.12.9 côté Dart
      ));

      Logger.Green.log("Sherpa-ONNX v1.12.9 prêt");
    } catch (e) {
      Logger.Red.log("Init Sherpa-ONNX échouée: $e");
    }
  }

  // ===== Start/Stop =====
  Future<void> _startListening() async {
    if (_recognizer == null) {
      Logger.Red.log("ASR non initialisé");
      _scheduleDeferredErrorDisplay();
      return;
    }

    // (re)crée un stream propre pour cette session
    _asrStream?.free();
    _asrStream = _recognizer!.createStream();

    final audioStream = await _recorder.startStream(const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: _sampleRate,
      numChannels: 1,
    ));

    _micSub = audioStream.listen((Uint8List chunk) {
      if (_recognizer == null || _asrStream == null) return;

      // ---- 1) RMS pour animation + silence ----
      final bd = ByteData.sublistView(chunk);
      final n = chunk.lengthInBytes ~/ 2;
      double sumsq = 0.0;
      for (var i = 0; i < n; i++) {
        final s = bd.getInt16(i * 2, Endian.little);
        final f = (s >= 0 ? s / 32767.0 : s / 32768.0);
        sumsq += f * f;
      }
      final rms = n > 0 ? sqrt(sumsq / n) : 0.0;

      if (mounted && isRecording) {
        setState(() {
          final base = 10.0;
          final amp = 40.0 * (rms.clamp(0.0, 0.2) / 0.2);
          _barHeights = List.generate(10, (i) => base + amp * (0.6 + 0.4 * Random().nextDouble()));
        });
      }

      // ---- 2) ASR: push + decode + partiel ----
      final Float32List f32 = _pcm16ToF32(chunk);
      _asrStream!.acceptWaveform(samples: f32, sampleRate: _sampleRate);

      while (_recognizer!.isReady(_asrStream!)) {
        _recognizer!.decode(_asrStream!);
      }

      final partial = (_recognizer!.getResult(_asrStream!).text ?? '').trim();
      if (partial.isNotEmpty) {
        final norm = replaceNumbersWithWords(partial);
        setState(() => _lastWords = norm);

        if (norm.toLowerCase() == vocabularyEnSelected.toLowerCase()) {
          isCorrect = true;
          viewResulte = true;
          _stopListening();
          return;
        }
      }

      // ---- 3) endpoint sherpa OU silence prolongé ----
      const double silenceRms = 0.01; // ~ -40 dBFS
      const int    maxSilMs   = 3000; // 1 seconde
      _lastAudioTs ??= DateTime.now();
      if (rms > silenceRms) _lastAudioTs = DateTime.now();

      if (_recognizer!.isEndpoint(_asrStream!) ||
          DateTime.now().difference(_lastAudioTs!).inMilliseconds > maxSilMs) {
        _finalizeAndStop();
      }
    }, onError: (e) {
      Logger.Red.log("Erreur flux micro: $e");
      _stopListening();
      _scheduleDeferredErrorDisplay();
    });
  }

  Future<void> _finalizeAndStop() async {
    try {
      await _micSub?.cancel();
      _micSub = null;
      await _recorder.stop();

      _asrStream?.inputFinished();

      // flush final
      while (_recognizer != null &&
          _asrStream != null &&
          _recognizer!.isReady(_asrStream!)) {
        _recognizer!.decode(_asrStream!);
      }

      final finalText = (_recognizer?.getResult(_asrStream!).text ?? '').trim();
      Logger.Green.log("Final: $finalText");
      final normalized = replaceNumbersWithWords(finalText);
      final ok = normalized.toLowerCase() == vocabularyEnSelected.toLowerCase();

      setState(() {
        _lastWords = normalized;
        isCorrect = ok;
        viewResulte = true;
      });
    } catch (e) {
      Logger.Red.log("Finalize error: $e");
    } finally {
      _stopAnimation();
      if (mounted) setState(() => isRecording = false);
    }
  }

  Future<void> _stopListening() async {
    try {
      await _micSub?.cancel();
      _micSub = null;
      await _recorder.stop();

      _asrStream?.inputFinished();

      while (_recognizer != null &&
          _asrStream != null &&
          _recognizer!.isReady(_asrStream!)) {
        _recognizer!.decode(_asrStream!);
      }

      final finalText = (_recognizer?.getResult(_asrStream!).text ?? '').trim();
      if (finalText.isNotEmpty) {
        Logger.Green.log("Final: $finalText");
        final normalized = replaceNumbersWithWords(finalText);
        final ok = normalized.toLowerCase() == vocabularyEnSelected.toLowerCase();
        setState(() {
          _lastWords = normalized;
          isCorrect = ok;
          viewResulte = true;
        });
      }
    } catch (_) {
    } finally {
      _stopAnimation();
      _cancelDeferredErrorDisplay();
      if (mounted) setState(() => isRecording = false);
    }
  }

  // ===== UI =====
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
          if (refrechRandom || randomItemData >= data.length) {
            refrechRandom = false;
            Random random = Random();
            randomItemData = random.nextInt(data.length);
            vocabularyEnSelected = data[randomItemData]['EN'];
          }

          final bool canTapRecord = _asrReady && _micReady && !_initInProgress;

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



              // === Bouton enregistrement (désactivé tant que !_asrReady || !_micReady || _initInProgress) ===
              IgnorePointer(
                ignoring: !canTapRecord || isRecording,
                child: GestureDetector(
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
                            color: isRecording
                                ? Colors.red
                                : (canTapRecord ? Colors.green : Colors.grey), // gris si désactivé
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
                              : (_initInProgress
                              ? const Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                              : const Icon(
                            Icons.mic_off,
                            size: 60,
                            color: Colors.white,
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Texte + résultat
              Column(
                children: [
                  const SizedBox(height: 0),
                  if (isRecording || viewResulte  || testScreenShot) ...[
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

                    Text(
                      testScreenShot
                          ? data[randomItemData][LanguageUtils.getSmallCodeLanguage(context: context)]
                          : _lastWords,
                      style: TextStyle(
                        fontSize: 24,
                        height:1,
                        fontWeight: FontWeight.bold,
                        color: isRecording
                            ? Colors.black54
                            : (isCorrect  || testScreenShot ? Colors.green : Colors.red),
                      ),
                    ),
                  ],

                  if (viewResulte || testScreenShot) ...[
                    SizedBox(height:10),
                    Text(
                      isCorrect  || testScreenShot
                          ? '✅ ${context.loc.pronunciation_success}'
                          : '❌ ${context.loc.pronunciation_error}',
                      style: TextStyle(
                        fontSize: isCorrect ? 40 : 20,
                        color:  isCorrect  || testScreenShot ? Colors.green : Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                        onPressed: _nextWord, // ne recharge pas l'écran
                        child: Text(context.loc.button_next),
                      ),
                    ),
                  ],
                ],
              ),

              // Petit hint si désactivé
              if (!canTapRecord && !_initInProgress)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _micReady
                        ? context.loc.unknown_error // tu peux mettre un message dédié “ASR non prêt…”
                        : 'Micro non autorisé',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          );
        } else if (state is VocabulairesError) {
          return Center(child: Text(context.loc.error_loading));
        } else {
          return Center(child: Text(context.loc.unknown_error));
        }
      },
    );
  }

  // ===== "Suivant" sans recharger l'écran =====
  void _nextWord() {
    setState(() {
      refrechRandom = true; // le build tirera un nouveau mot
      viewResulte = false;
      isCorrect = false;
      _lastWords = '';
      _barHeights = List.generate(10, (_) => 10);
    });
  }

  // ===== Animations =====
  void _startAnimation() {
    _animationController.repeat(reverse: true);
    _barUpdateTimer = Timer.periodic(const Duration(milliseconds: 180), (_) {
      if (!mounted || !isRecording) return;
      setState(() {}); // barres mises à jour par le RMS
    });
  }

  void _stopAnimation() {
    _animationController.stop();
    _animationController.reset();
    _barUpdateTimer?.cancel();
  }

  // ===== Gestion erreur différée =====
  void _scheduleDeferredErrorDisplay() {
    _errorDelayTimer?.cancel();
    _errorDelayTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
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

  // Bouton mic — UI instantanée + ASR en arrière-plan
  void _toggleRecording() async {
    // sécurité: on ignore si pas prêt
    if (!_asrReady || !_micReady || _initInProgress) return;

    if (isRecording) {
      await _stopListening();
    } else {
      // feedback immédiat
      _resetRecordingState();
      _lastAudioTs = DateTime.now();
      setState(() {
        isRecording = true;
        viewResulte = false;
      });
      _startAnimation();

      // lancer l'écoute sans bloquer l'UI
      // ignore: unawaited_futures
      _startListening();
    }
  }

  // ===== Util =====
  String replaceNumbersWithWords(String input) {
    final Map<String, String> numberWords = {
      '0': 'zero','1': 'one','2': 'two','3': 'three','4': 'four','5': 'five',
      '6': 'six','7': 'seven','8': 'eight','9': 'nine','10': 'ten','11': 'eleven',
      '12': 'twelve','13': 'thirteen','14': 'fourteen','15': 'fifteen','16': 'sixteen',
      '17': 'seventeen','18': 'eighteen','19': 'nineteen','20': 'twenty',
      '25': 'twenty-five','30': 'thirty','50': 'fifty','100': 'one hundred',
    };
    final regex = RegExp(r'\b\d+\b');
    return input.replaceAllMapped(regex, (m) => numberWords[m.group(0)] ?? m.group(0)!);
  }

  Float32List _pcm16ToF32(Uint8List bytes) {
    final bd = ByteData.sublistView(bytes);
    final len = bytes.lengthInBytes ~/ 2;
    final out = Float32List(len);
    for (var i = 0; i < len; i++) {
      final s = bd.getInt16(i * 2, Endian.little);
      out[i] = (s >= 0 ? s / 32767.0 : s / 32768.0);
    }
    return out;
  }
}

// ====== UI helper ======
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
          border: Border.all(color: color, width: 2),
        ),
      ),
    );
  }
}
