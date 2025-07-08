import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';

Padding titleWidget({required String text}){
  return Padding(
      padding: EdgeInsets.only(top:10),
      child:AutoSizeText(
        text,
        style: TextStyle(
          fontFamily: GoogleFonts.titanOne().fontFamily,
          fontSize: 22,
          height: 1,
          color: Colors.black,
          decoration: TextDecoration.none,
        ),
        maxLines: 2,

        minFontSize: 22,
        overflow: TextOverflow.ellipsis,
      )
  );

}
