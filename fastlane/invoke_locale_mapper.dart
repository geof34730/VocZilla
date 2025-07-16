import 'dart:io';

// Ce script est un pont (bridge) exécutable. Il importe la bibliothèque
// `locale_mapper.dart` et expose ses fonctions à Fastlane via la ligne de commande.
// Il ne contient aucune logique de mappage lui-même.
import 'locale_mapper.dart';

/// Point d'entrée pour Fastlane.
///
/// Prend deux arguments : la plateforme (`ios` ou `android`) et la locale (`fr`, `en-GB`, etc.).
/// Il appelle la fonction de mappage correspondante de `locale_mapper.dart` et
/// imprime le résultat sur la sortie standard (stdout).
///
/// Si le mappage échoue (la fonction retourne `null`), le script ne produit
/// aucune sortie, et Fastlane ignorera cette locale.
///
/// Usage: dart fastlane/invoke_locale_mapper.dart [platform] [locale]
void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('Usage: dart fastlane/invoke_locale_mapper.dart [ios|android] [locale]');
    exit(1);
  }

  final platform = args[0];
  final locale = args[1];
  String? mappedLocale;

  if (platform == 'ios') {
    mappedLocale = toAppleLocale(locale);
  } else if (platform == 'android') {
    mappedLocale = toPlayLocale(locale);
  }

  if (mappedLocale != null) {
    stdout.write(mappedLocale);
  }
}