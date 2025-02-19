import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vobzilla/global.dart';
import 'package:vobzilla/ui/theme/appColors.dart';

Stack TitleSite() {
  double typoSize = 45;
  double strokeWidth = typoSize/4;
  dynamic typoGoogle = GoogleFonts.titanOne().fontFamily;
  return Stack(
    children: [
      Text(
        titleApp,
        style: TextStyle(
          fontFamily: typoGoogle,
          fontSize: typoSize,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..color = Colors.black,
        ),
      ),
      RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: typoGoogle,
            fontSize: typoSize,
          ),
          children: [
            TextSpan(
              text: titleApp.substring(0,titleAppCute1),
              style: TextStyle(color: Colors.white),
            ),
            TextSpan(
              text: titleApp.substring(titleAppCute1),
              style: TextStyle(color: AppColors.colorTextTitle),
            ),
          ],
        ),
      ),
    ],
  );
}
