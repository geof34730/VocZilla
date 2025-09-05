import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'logger.dart';

bool isTablet(BuildContext context) {
  // Material Design guidelines recommend 600dp as the breakpoint for tablets.
  final shortestSide = MediaQuery.of(context).size.shortestSide;
  return shortestSide >= 600;
}
Future<String?> getPlatformDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  String? deviceId;

  try {
    if (kIsWeb) {
      // Le Web n'a pas d'ID d'appareil stable. C'est une solution de contournement.
      final webInfo = await deviceInfo.webBrowserInfo;
      deviceId = webInfo.vendor.toString() + webInfo.userAgent.toString() + webInfo.hardwareConcurrency.toString();
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;
    } else if (Platform.isMacOS) {
      final macOsInfo = await deviceInfo.macOsInfo;
      deviceId = macOsInfo.systemGUID;
    }
  } catch (e) {
    Logger.Red.log("Erreur lors de la récupération du Device ID: $e");
    return null; // Retourne null en cas d'erreur
  }

  // Vérification cruciale : s'assurer que l'ID n'est ni null, ni vide.
  if (deviceId != null && deviceId.isNotEmpty) {
    return deviceId;
  } else {
    Logger.Yellow.log("L'ID de l'appareil récupéré est null ou vide.");
    return null;
  }
}
