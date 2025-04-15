import 'package:flutter/material.dart';


class LanguageUtils{

  String getSmallCodeLanguage({required BuildContext context}) {
    Locale locale = Localizations.localeOf(context);
    return locale.languageCode.toUpperCase();
  }
}
