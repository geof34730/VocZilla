import 'package:flutter/material.dart';

class LanguageUtils {
  // Transformée en méthode statique
  static String getSmallCodeLanguage({required BuildContext context}) {
    Locale locale = Localizations.localeOf(context);
    return locale.languageCode.toUpperCase();
  }
}
