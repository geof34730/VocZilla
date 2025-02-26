import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

String localGenerateNonce([int length = 32]) {
  const charset ='LoremIpsum6545dsf1121df^^^!8e2d88=';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

/// Returns the sha256 hash of [input] in hex notation.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
