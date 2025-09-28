import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // rootBundle
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart'; // v6.x -> AudioRecorder
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart'; // v1.12.9
import 'package:google_mobile_ads/google_mobile_ads.dart';
// 🔥 Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/utils/detailTypeVocabulaire.dart';
import '../../../global.dart';
import '../../widget/ads/banner_ad_widget.dart';
import '../../widget/elements/PlaySoond.dart';
import '../../../core/utils/languageUtils.dart';
import '../../../core/utils/localization.dart';
import '../../../core/utils/logger.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';

class PronunciationScreen extends StatefulWidget {
  PronunciationScreen({required String listName});

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
  double? _downloadProgress;
  String? _downloadError;

  // Correctif homophones (lettres + mots)
  bool _homophonesFix = true;

  // ===== GESTION DES MODÈLES ASR (TÉLÉCHARGEMENT) =====
  // Afficher la barre de progression UNIQUEMENT quand un vrai téléchargement a lieu
  bool _showModelDownloadUi = false;

  // ⚠️ Plus d'URL bricolée : on passe par FirebaseStorage.ref(...).getDownloadURL()
  final Map<String, String> _modelFiles = {
    'tokens': 'tokens.txt',
    'encoder': 'encoder-epoch-99-avg-1.int8.onnx',
    'decoder': 'decoder-epoch-99-avg-1.int8.onnx',
    'joiner': 'joiner-epoch-99-avg-1.int8.onnx',
  };

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
    // 🚫 Mode screenshot : on ne touche pas au micro ni à l'ASR
    if (testScreenShot) {
      Logger.Yellow.log("Screenshot mode: ASR/micro désactivés");
      setState(() {
        _initInProgress = false; // pas de loader
        _asrReady = false;
        _micReady = false;
      });
      return;
    }

    setState(() {
      _initInProgress = true;
      _asrReady = false;
      _downloadError = null;
    });

    if (!(await _ensureMic())) {
      Logger.Red.log("Microphone permission denied");
      setState(() {
        _initInProgress = false; // on arrête l’init (bouton restera grisé hors screenshot)
      });
      return;
    }

    // 🔥 S'assurer que Firebase est initialisé (au cas où)
    try {
      Firebase.apps.isEmpty ? await Firebase.initializeApp() : null;
    } catch (e) {
      // si déjà initialisé ailleurs, on ignore
      Logger.Yellow.log('Firebase init skip/ok: $e');
    }

    // Étape 2: S'assurer que les modèles sont prêts (téléchargement si besoin)
    final modelsReady = await _ensureModelsAreReady();
    if (!modelsReady) {
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

  // ===== Gestion des modèles ASR =====

  Future<String> _getLocalModelPath(String fileName) async {
    final dir = await getApplicationSupportDirectory();
    return '${dir.path}/asr_en/$fileName';
  }

  // --- Helper : validation rapide d’un vrai fichier ONNX (évite le crash natif)
  Future<bool> _looksLikeOnnx(File f) async {
    final len = await f.length();
    if (len < 1024) return false; // trop petit pour être un modèle
    try {
      final head = await f.openRead(0, 64).fold<BytesBuilder>(
        BytesBuilder(),
            (b, d) { b.add(d); return b; },
      );
      final s = String.fromCharCodes(head.takeBytes());
      if (s.startsWith('<!DOCTYPE') || s.startsWith('<html') || s.startsWith('{')) return false; // HTML/JSON
    } catch (_) {
      return false;
    }
    return true;
  }

  /// (Optionnel) Reset complet du cache modèles pour forcer un redownload propre
  Future<void> _clearLocalModels() async {
    final dir = await getApplicationSupportDirectory();
    final modelsDir = Directory('${dir.path}/asr_en');
    if (await modelsDir.exists()) {
      await modelsDir.delete(recursive: true).catchError((_) {});
      Logger.Yellow.log("Cache des modèles supprimé.");
    }
  }

  /// Vérifie si les modèles sont présents localement, sinon les télécharge via Firebase Storage.
  Future<bool> _ensureModelsAreReady() async {
    final dio = Dio();
    final localPaths = <String, String>{};

    try {
      // 1) Pré-check: tout est déjà là ? (pas d'UI de téléchargement dans ce cas)
      bool needsDownload = false;
      for (var i = 0; i < _modelFiles.entries.length; i++) {
        final entry = _modelFiles.entries.elementAt(i);
        final key = entry.key; // tokens | encoder | decoder | joiner
        final fileName = entry.value;
        final localPath = await _getLocalModelPath(fileName);
        final file = File(localPath);

        if (await file.exists()) {
          final ok = key == 'tokens' ? (await file.length()) > 0 : await _looksLikeOnnx(file);
          if (ok) {
            localPaths[key] = localPath;
            continue;
          } else {
            needsDownload = true;
          }
        } else {
          needsDownload = true;
        }
      }

      if (!needsDownload) {
        // Rien à télécharger, on renseigne les chemins et on sort sans afficher la barre
        _fTokens  = localPaths['tokens'];
        _fEncoder = localPaths['encoder'];
        _fDecoder = localPaths['decoder'];
        _fJoiner  = localPaths['joiner'];
        return true;
      }

      // 2) Téléchargement nécessaire → on affiche la barre
      if (mounted) setState(() { _showModelDownloadUi = true; _downloadProgress = 0.0; });

      for (var i = 0; i < _modelFiles.entries.length; i++) {
        final entry = _modelFiles.entries.elementAt(i);
        final key = entry.key;
        final fileName = entry.value;
        final localPath = await _getLocalModelPath(fileName);
        final file = File(localPath);

        // Si fichier présent mais invalide, on le supprime avant redownload
        if (await file.exists()) {
          final ok = key == 'tokens' ? (await file.length()) > 0 : await _looksLikeOnnx(file);
          if (!ok) { await file.delete().catchError((_) {}); }
        }

        if (!await file.exists()) {
          Logger.Yellow.log("Modèle '$fileName' non trouvé, téléchargement (Firebase Storage)...");
          await file.create(recursive: true);

          // Télécharge via SDK (plus robuste) avec progression
          final ref = FirebaseStorage.instance.ref('models/$fileName');
          final task = ref.writeToFile(file);
          task.snapshotEvents.listen((snap) {
            if (snap.totalBytes > 0 && mounted) {
              final prog = snap.bytesTransferred / snap.totalBytes;
              setState(() => _downloadProgress = (i + prog) / _modelFiles.length);
            }
          });
          await task;
          Logger.Green.log("Modèle '$fileName' téléchargé via Firebase Storage.");
        } else {
          Logger.Green.log("Modèle '$fileName' trouvé localement.");
        }

        // Validation finale
        final ok = key == 'tokens' ? (await file.length()) > 0 : await _looksLikeOnnx(file);
        if (!ok) {
          await file.delete().catchError((_) {});
          final msg = "Le fichier $fileName est corrompu. Réessaie le téléchargement.";
          Logger.Red.log(msg);
          if (mounted) setState(() => _downloadError = msg);
          return false;
        }

        localPaths[key] = localPath;
      }

      _fTokens  = localPaths['tokens'];
      _fEncoder = localPaths['encoder'];
      _fDecoder = localPaths['decoder'];
      _fJoiner  = localPaths['joiner'];
      return true;

    } catch (e) {
      Logger.Red.log("Échec du téléchargement des modèles ASR: $e");
      if (mounted) setState(() => _downloadError = "Vérifie ta connexion ou les autorisations Firebase Storage.");
      return false;
    } finally {
      if (mounted) setState(() { _downloadProgress = null; _showModelDownloadUi = false; });
    }
  }

  // ===== Init Sherpa-ONNX (API 1.12.9) =====
  Future<void> _initSherpaOnnx() async {
    try {
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
    if (testScreenShot) return; // 🛑 blocage total en screenshot
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
          // animation plus visible
          final base = 5.0;
          final amp = 80.0 * (rms.clamp(0.0, 0.3) / 0.3);
          _barHeights = List.generate(10, (i) => base + amp * (0.5 + 0.5 * Random().nextDouble()));
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
        var norm = replaceNumbersWithWords(partial);
        norm = normalizeHomophonesForTarget(norm, vocabularyEnSelected); // << homophones
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
      const int    maxSilMs   = 3000; // 3 secondes
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

  /// Arrête l'enregistrement et récupère le texte final de l'ASR.
  Future<String> _stopRecordingAndGetFinalText() async {
    await _micSub?.cancel();
    _micSub = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }

    if (_recognizer == null || _asrStream == null) return '';

    _asrStream!.inputFinished();
    while (_recognizer!.isReady(_asrStream!)) {
      _recognizer!.decode(_asrStream!);
    }
    return (_recognizer!.getResult(_asrStream!).text ?? '').trim();
  }

  Future<void> _finalizeAndStop() async {
    if (!isRecording) return; // Évite les appels multiples
    try {
      final finalText = await _stopRecordingAndGetFinalText();
      Logger.Green.log("Final (silence/endpoint): $finalText");
      var normalized = replaceNumbersWithWords(finalText);
      normalized = normalizeHomophonesForTarget(normalized, vocabularyEnSelected); // << homophones
      final ok = normalized.toLowerCase() == vocabularyEnSelected.toLowerCase();

      if (mounted) {
        setState(() {
          _lastWords = normalized;
          isCorrect = ok;
          viewResulte = true;
        });
      }
    } catch (e) {
      Logger.Red.log("Finalize error: $e");
    } finally {
      _stopAnimation();
      if (mounted) setState(() => isRecording = false);
    }
  }

  Future<void> _stopListening() async {
    if (!isRecording) return; // Évite les appels multiples
    try {
      final finalText = await _stopRecordingAndGetFinalText();
      if (finalText.isNotEmpty) {
        Logger.Green.log("Final (user stop): $finalText");
        var normalized = replaceNumbersWithWords(finalText);
        normalized = normalizeHomophonesForTarget(normalized, vocabularyEnSelected); // << homophones
        final ok = normalized.toLowerCase() == vocabularyEnSelected.toLowerCase();
        if (mounted) {
          setState(() {
            _lastWords = normalized;
            isCorrect = ok;
            viewResulte = true;
          });
        }
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

          // ✅ En screenshot, on n’intègre PAS testScreenShot ici :
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
                        "${data[randomItemData]["TRAD"]}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        "(${getTypeDetaiVocabulaire(typeDetail:data[randomItemData]['TYPE_DETAIL'],context: context)})",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12
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

              // === Indicateur de téléchargement/erreur pendant l'init ===
              if (_initInProgress && !_asrReady && _showModelDownloadUi)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                  child: Column(
                    children: [
                      if (_downloadProgress != null) ...[
                        Text(
                          "${context.loc.downloading_models} (${(_downloadProgress! * 100).toStringAsFixed(0)}%)",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: _downloadProgress),
                      ],
                      if (_downloadError != null) ...[
                        const SizedBox(height: 8),
                        const Icon(Icons.error_outline, color: Colors.red, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          "${context.loc.error_downloading_models}: $_downloadError",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),

              // === Bouton enregistrement ===
              IgnorePointer(
                // En screenshot: jamais ignoré (cliquable), sinon logique habituelle
                ignoring: ((!canTapRecord || isRecording) && !testScreenShot),
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
                                : (testScreenShot
                                ? Colors.green // 🟢 En screenshot: vert
                                : (canTapRecord ? Colors.green : Colors.grey)),
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
                  AdaptiveBannerAdWidget(padding:EdgeInsets.only(top:8)),
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
                          ? data[randomItemData]["TRAD"]
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

              // Petit hint si désactivé (🚫 pas en screenshot)
              if (!canTapRecord && !_initInProgress && !testScreenShot)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _micReady
                        ? (_downloadError ?? context.loc.unknown_error)
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
    if (testScreenShot) return; // 🛑 pas d’action en mode screenshot
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

  String _canon(String s) => s.trim().toLowerCase().replaceAll('’', "'");

  /// Corrige lettres & homophones: si `recognized` et `expected` appartiennent au même set,
  /// on force la sortie sur `expected`. S'applique seulement aux réponses d'un seul mot.
  String normalizeHomophonesForTarget(String recognized, String expected) {
    if (!_homophonesFix) return recognized;
    final rRaw = recognized.trim();
    if (rRaw.isEmpty) return recognized;
    if (rRaw.split(RegExp(r'\s+')).length > 1) return recognized;

    final r = _canon(rRaw);
    final e = _canon(expected);

    const List<Set<String>> homophoneSets = [
      // Lettres ~ mots
      {'a'},
      {'b', 'be', 'bee'},
      {'c', 'see', 'sea'},
      {'d', 'dee'},
      {'e'},
      {'f', 'ef', 'eff'},
      {'g', 'gee'},
      {'h', 'aitch'},
      {'i', 'eye'},
      {'j', 'jay'},
      {'k', 'kay'},
      {'l', 'el'},
      {'m', 'em'},
      {'n', 'en'},
      {'o', 'oh', 'owe'},
      {'p', 'pee', 'pea'},
      {'q', 'cue', 'queue'},
      {'r', 'are', 'ar'},
      {'s', 'ess'},
      {'t', 'tee', 'tea'},
      {'u', 'you', 'yew'},
      {'v', 'vee'},
      {'w', 'double u', 'double-u', 'doubleu'},
      {'x', 'ex'},
      {'y', 'why'},
      {'z', 'zee', 'zed'},

      // Mots ~ mots (fréquents)
      {'to', 'too', 'two'},
      {'for', 'four', 'fore'},
      {"there", "their", "they're"},
      {'your', "you're"},
      {'by', 'buy', 'bye'},
      {'one', 'won'},
      {'no', 'know'},
      {'here', 'hear'},
      {'which', 'witch'},
      {'weather', 'whether'},
      {'bear', 'bare'},
      {'break', 'brake'},
      {'cell', 'sell'},
      {'flower', 'flour'},
      {'hole', 'whole'},
      {'peace', 'piece'},
      {'pair', 'pare', 'pear'},
      {'pain', 'pane'},
      {'son', 'sun'},
      {'some', 'sum'},
      {'wait', 'weight'},
      {'week', 'weak'},
      {'would', 'wood'},
      {'new', 'knew'},
      {'meat', 'meet'},
      {'road', 'rode', 'rowed'},
      {'plane', 'plain'},
      {'stair', 'stare'},
      {'mail', 'male'},
      {'morning', 'mourning'},
      {'so', 'sew', 'sow'},
    ];

    for (final set in homophoneSets) {
      if (set.contains(r) && set.contains(e)) {
        return expected;
      }
    }
    return recognized;
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
