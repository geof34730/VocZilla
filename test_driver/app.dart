// test_driver/app.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io'; // <-- pour Platform.environment

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:vobzilla/app_route.dart';
import 'package:vobzilla/main.dart' as app;
// import '../lib/core/utils/navigatorKey.dart' show navigatorKey; // si besoin

/// Configuration transmise par le test au runtime
class _DriverRuntimeConfig {
  String platform;        // 'ios' | 'android' | 'macos'
  String destFolder;      // ex: 'iphone6_7_inch' | 'desktop'
  String locale;          // ex: 'fr'
  bool forFeatureGraphic; // ex: false

  _DriverRuntimeConfig({
    required this.platform,
    required this.destFolder,
    required this.locale,
    required this.forFeatureGraphic,
  });

  /// Lecture robuste : d'abord variables d'environnement (Fastlane),
  /// sinon fallback vers --dart-define (fromEnvironment), sinon valeurs par défaut.
  factory _DriverRuntimeConfig.defaults() {
    final env = Platform.environment;
    String platform = env['PLATFORM'] ??
        const String.fromEnvironment('PLATFORM', defaultValue: 'android');
    String destFolder = env['DESTFOLDER'] ??
        const String.fromEnvironment('DESTFOLDER', defaultValue: '');
    String locale = env['LOCALE'] ??
        const String.fromEnvironment('LOCALE', defaultValue: 'en');

    bool forFeatureGraphic =
        _parseBoolEnv(env['FOR_FEATURE_GRAPHIC']) ??
            const bool.fromEnvironment('FOR_FEATURE_GRAPHIC', defaultValue: false);

    // normalisation ultra simple (au cas où)
    platform = platform.trim().toLowerCase();
    if (platform.isEmpty) platform = 'android';

    return _DriverRuntimeConfig(
      platform: platform,
      destFolder: destFolder,
      locale: locale,
      forFeatureGraphic: forFeatureGraphic,
    );
  }

  void applyFromJson(Map<String, dynamic> json) {
    if (json.containsKey('platform')) {
      platform = (json['platform'] ?? platform).toString().trim().toLowerCase();
    }
    if (json.containsKey('destFolder')) {
      destFolder = (json['destFolder'] ?? destFolder).toString();
    }
    if (json.containsKey('locale')) {
      locale = (json['locale'] ?? locale).toString();
    }
    if (json.containsKey('feature') || json.containsKey('forFeatureGraphic')) {
      final v = (json['feature'] ?? json['forFeatureGraphic']);
      forFeatureGraphic = (v == true) ||
          (v is String && (v.toLowerCase() == 'true' || v == '1'));
    }
  }

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'destFolder': destFolder,
    'locale': locale,
    'forFeatureGraphic': forFeatureGraphic,
  };
}

bool? _parseBoolEnv(String? v) {
  if (v == null) return null;
  final s = v.trim().toLowerCase();
  if (s == 'true' || s == '1' || s == 'yes' || s == 'y') return true;
  if (s == 'false' || s == '0' || s == 'no' || s == 'n') return false;
  return null;
}

final _config = _DriverRuntimeConfig.defaults();
final Completer<void> _configReady = Completer<void>();

void main() async {
  // 1) Activer l’extension Driver AVANT tout
  enableFlutterDriverExtension(handler: (String? message) async {
    final msg = message ?? '';

    // Nouveau protocole: "setConfig:{json}"
    // Exemple côté test:
    // await driver.requestData(json.encode({
    //   "cmd":"setConfig",
    //   "platform":"macos",
    //   "locale":"cs",
    //   "destFolder":"desktop",
    //   "feature": false
    // }));
    try {
      if (msg.isNotEmpty) {
        Map<String, dynamic>? parsed;
        if (msg.startsWith('setConfig:')) {
          parsed = json.decode(msg.substring('setConfig:'.length).trim())
          as Map<String, dynamic>;
          parsed['cmd'] ??= 'setConfig';
        } else if (msg.trimLeft().startsWith('{')) {
          parsed = json.decode(msg) as Map<String, dynamic>;
        }

        if (parsed != null) {
          final cmd = (parsed['cmd'] ?? '').toString();
          if (cmd == 'setConfig') {
            _config.applyFromJson(parsed);
            if (!_configReady.isCompleted) {
              _configReady.complete(); // réveille main() qui attend la config
            }
            return 'ok';
          }
          if (cmd == 'getConfig') {
            return json.encode(_config.toJson());
          }
        }
      }
    } catch (_) {
      // ne pas crasher si JSON mal formé
    }

    // Backwards compatibility
    if (msg == 'getForFeatureGraphic') return _config.forFeatureGraphic.toString();
    if (msg == 'getPlatform') return _config.platform;
    if (msg == 'getDestFolder') return _config.destFolder;

    return '';
  });

  // 2) Attendre une éventuelle config envoyée par le test (timeout pour run manuel)
  try {
    await _configReady.future.timeout(const Duration(seconds: 3));
  } catch (_) {
    // Timeout → on continue avec les valeurs par défaut (env/--define)
  }

  // 3) Démarrer l’app avec les paramètres dynamiques
  WidgetsFlutterBinding.ensureInitialized();

  // Log utile en CI
  // (tu peux retirer si verbeux)
  // ignore: avoid_print
  print('[driver] runtime config: ${_config.toJson()}');

  app.main(
    shootScreenShot: true,
    localForce: _config.locale,
    forFeatureGraphicParam: _config.forFeatureGraphic,
    // si besoin: passe _config.platform / _config.destFolder à main()
    // pour gérer des comportements spécifiques (taille fenêtre macOS, etc.)
  );
}
