// test_driver/app.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:voczilla/app_route.dart';
import 'package:voczilla/main.dart' as app;

/// Configuration transmise par le test au runtime
class _DriverRuntimeConfig {
  String platform;        // 'ios' | 'android' | 'macos'
  String destFolder;      // ex: 'iphone6_7_inch' | 'desktop'
  String locale;          // ex: 'fr'
  bool forFeatureGraphic;
  bool forFeatureGraphicVoczillaCom; // ex: false

  _DriverRuntimeConfig({
    required this.platform,
    required this.destFolder,
    required this.locale,
    required this.forFeatureGraphic,
    required this.forFeatureGraphicVoczillaCom,
  });

  /// Lecture robuste : d'abord variables d'environnement (CI/Fastlane),
  /// sinon fallback vers --dart-define, sinon valeurs par défaut.
  factory _DriverRuntimeConfig.defaults() {
    final env = Platform.environment;

    String platform = env['PLATFORM'] ??
        const String.fromEnvironment('PLATFORM', defaultValue: 'android');

    String destFolder = env['DESTFOLDER'] ??
        const String.fromEnvironment('DESTFOLDER', defaultValue: '');

    String locale = env['LOCALE'] ??
        const String.fromEnvironment('LOCALE', defaultValue: 'en');

    // Feature (globale)
    bool forFeatureGraphic =
        _parseBoolEnv(env['FOR_FEATURE_GRAPHIC']) ??
            const bool.fromEnvironment('FOR_FEATURE_GRAPHIC', defaultValue: false);

    // Feature (voczilla.com) — harmonisé avec le test
    bool forFeatureGraphicVoczillaCom =
        _parseBoolEnv(env['FOR_FEATURE_GRAPHIC_VOCZILLA_COM']) ??
            const bool.fromEnvironment('FOR_FEATURE_GRAPHIC_VOCZILLA_COM', defaultValue: false);

    // Normalisation simple
    platform = platform.trim().toLowerCase();
    if (platform.isEmpty) platform = 'android';

    return _DriverRuntimeConfig(
      platform: platform,
      destFolder: destFolder,
      locale: locale,
      forFeatureGraphic: forFeatureGraphic,
      forFeatureGraphicVoczillaCom: forFeatureGraphicVoczillaCom,
    );
  }

  // Petit helper bool
  bool _toBool(dynamic v, {bool fallback = false}) {
    if (v is bool) return v;
    if (v is String) {
      final s = v.trim().toLowerCase();
      if (s == 'true' || s == '1' || s == 'yes' || s == 'y') return true;
      if (s == 'false' || s == '0' || s == 'no' || s == 'n') return false;
    }
    return fallback;
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
    // Feature (globale) — accepte 'feature' ou 'forFeatureGraphic'
    if (json.containsKey('feature') || json.containsKey('forFeatureGraphic')) {
      final v = (json['feature'] ?? json['forFeatureGraphic']);
      forFeatureGraphic = _toBool(v, fallback: forFeatureGraphic);
    }
    // Feature (voczilla.com) — accepte 'featureVoczillaCom' ou 'forFeatureGraphicVoczillaCom'
    if (json.containsKey('featureVoczillaCom') ||
        json.containsKey('forFeatureGraphicVoczillaCom')) {
      final v = (json['featureVoczillaCom'] ?? json['forFeatureGraphicVoczillaCom']);
      forFeatureGraphicVoczillaCom = _toBool(v, fallback: forFeatureGraphicVoczillaCom);
    }
  }

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'destFolder': destFolder,
    'locale': locale,
    'forFeatureGraphic': forFeatureGraphic,
    'forFeatureGraphicVoczillaCom': forFeatureGraphicVoczillaCom,
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

    // Supporte JSON brut ou "setConfig:{json}"
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

    // Compatibilité ascendante avec l'ancien protocole
    if (msg == 'getForFeatureGraphic') {
      return _config.forFeatureGraphic.toString();
    }
    if (msg == 'getForFeatureGraphicVoczillaCom') {
      return _config.forFeatureGraphicVoczillaCom.toString();
    }
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
  // ignore: avoid_print
  print('[driver] runtime config: ${_config.toJson()}');

  app.main(
    shootScreenShot: true,
    localForce: _config.locale,
    forFeatureGraphicParam: _config.forFeatureGraphic,
    forFeatureGraphicVoczillaComParam: _config.forFeatureGraphicVoczillaCom,
  );
}
