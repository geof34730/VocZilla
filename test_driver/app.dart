// test_driver/app.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:vobzilla/app_route.dart';
import 'package:vobzilla/main.dart' as app;
// Si tu utilises un navigatorKey global, garde l'import :
// import '../lib/core/utils/navigatorKey.dart' show navigatorKey;

/// Configuration transmise par le test au runtime
class _DriverRuntimeConfig {
  String platform;        // 'ios' | 'android'
  String destFolder;      // ex: 'iphone6_7_inch'
  String locale;          // ex: 'fr'
  bool forFeatureGraphic; // ex: false

  _DriverRuntimeConfig({
    required this.platform,
    required this.destFolder,
    required this.locale,
    required this.forFeatureGraphic,
  });

  factory _DriverRuntimeConfig.defaults() => _DriverRuntimeConfig(
    platform: const String.fromEnvironment('PLATFORM', defaultValue: 'android'),
    destFolder: const String.fromEnvironment('DESTFOLDER', defaultValue: ''),
    locale: const String.fromEnvironment('LOCALE', defaultValue: 'en'),
    forFeatureGraphic: const bool.fromEnvironment('FOR_FEATURE_GRAPHIC', defaultValue: false),
  );

  void applyFromJson(Map<String, dynamic> json) {
    if (json.containsKey('platform')) platform = (json['platform'] ?? platform).toString();
    if (json.containsKey('destFolder')) destFolder = (json['destFolder'] ?? destFolder).toString();
    if (json.containsKey('locale')) locale = (json['locale'] ?? locale).toString();
    if (json.containsKey('feature') || json.containsKey('forFeatureGraphic')) {
      forFeatureGraphic = (json['feature'] ?? json['forFeatureGraphic'] ?? forFeatureGraphic) == true;
    }
  }

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'destFolder': destFolder,
    'locale': locale,
    'forFeatureGraphic': forFeatureGraphic,
  };
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
    //   "platform":"ios",
    //   "locale":"cs",
    //   "destFolder":"iphone6_7_inch",
    //   "feature": false
    // }));
    try {
      if (msg.isNotEmpty) {
        // On accepte soit un simple JSON {cmd:..., ...}, soit "setConfig:{...}".
        Map<String, dynamic>? parsed;
        if (msg.startsWith('setConfig:')) {
          parsed = json.decode(msg.substring('setConfig:'.length).trim()) as Map<String, dynamic>;
          if (parsed['cmd'] == null) parsed['cmd'] = 'setConfig';
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
      // On évite de crasher l’handler si un JSON est mal formé
    }

    // Backwards compatibility avec tes anciens messages "getX"
    if (msg == 'getForFeatureGraphic') return _config.forFeatureGraphic.toString();
    if (msg == 'getPlatform') return _config.platform;
    if (msg == 'getDestFolder') return _config.destFolder;

    return '';
  });

  // 2) Attendre la config envoyée par le test (avec timeout pour ne pas bloquer en run manuel)
  //    Le driver peut envoyer requestData juste après la connexion.
  try {
    await _configReady.future.timeout(const Duration(seconds: 3));
  } catch (_) {
    // Timeout → on continue avec les valeurs par défaut (compile-time ou précédentes)
  }

  // 3) Lancer ton app avec les paramètres dynamiques
  //    Tu passais déjà localForce à main(); on le garde pour initialiser la locale.
  WidgetsFlutterBinding.ensureInitialized();
  app.main(
    shootScreenShot: true,
    localForce: _config.locale,
    forFeatureGraphicParam: _config.forFeatureGraphic,
    // Si tu veux exposer d’autres paramètres à ton app.main, tu peux les ajouter ici
    // et gérer côté `main.dart` (ex: platformStore, destFolder, feature, etc.)
  );
}
