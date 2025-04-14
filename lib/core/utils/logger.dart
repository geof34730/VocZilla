import 'dart:io';

import '../../global.dart';

enum Logger {
  Black("30"),
  Red("31"),
  Green("32"),
  Yellow("33"),
  Blue("34"),
  Magenta("35"),
  Cyan("36"),
  White("37"),
  Pink("95");

  final String code;
  const Logger(this.code);

  void log(dynamic text) {
    if (debugMode) {
      if (Platform.isAndroid || Platform.isLinux || Platform.isMacOS) {
        // Utiliser les couleurs ANSI sur les plateformes qui les supportent
        print('\x1B[' + code + 'm' + text.toString() + '\x1B[0m');
      } else {
        // Pas de couleur sur iOS ou d'autres plateformes
        print(text.toString());
      }
    }
  }
}
