import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voczilla/core/utils/localization.dart';

import '../../../core/utils/getFontForLanguage.dart';

Padding titleWidget({required String text, required String codelang, int maxLine = 2}){
  return Padding(
      padding: EdgeInsets.only(top:10),
      child:AutoSizeText(
        text,
        style: getFontForLanguage(
          codelang: codelang,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          // Tu peux ajouter fontWeight si besoin
        ).copyWith(
          height: 1,
          color: Colors.black,
          decoration: TextDecoration.none,
        ),
        maxLines: maxLine,

        minFontSize: 22,
        overflow: TextOverflow.ellipsis,
      )
  );

}
