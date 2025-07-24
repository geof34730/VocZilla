import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

double _getAdjustedFontSize(String codelang, double? titanOneFontSize) {
  final baseSize = titanOneFontSize ?? 16.0;
  switch (codelang) {
    case 'ar':
      return baseSize * 1.12;
    case 'uk':
    case 'ru':
    case 'bg':
      return baseSize * 1.0;
    case 'zh':
      return baseSize * 0.92;
    case 'ja':
      return baseSize * 0.95;
    case 'ko':
      return baseSize * 0.98;
    case 'th':
      return baseSize * 1.05;
    case 'he':
      return baseSize * 1.08;
    case 'el':
      return baseSize * 1.0;
    default:
      return baseSize;
  }
}

TextStyle getFontForLanguage({
  required String codelang,
  double? fontSize,
  FontWeight? fontWeight,
}) {
  final adjustedFontSize = _getAdjustedFontSize(codelang, fontSize);

  switch (codelang) {
    case 'uk':
    case 'ru':
    case 'bg':
      return GoogleFonts.roboto(
        fontSize: adjustedFontSize,
        fontWeight: fontWeight,
      );
    case 'ar':
      return GoogleFonts.notoSansArabic(
        fontSize: adjustedFontSize,
        fontWeight: fontWeight,
      );
    case 'he':
      return GoogleFonts.notoSansHebrew(
        fontSize: adjustedFontSize,
        fontWeight: fontWeight,
      );
    case 'el': // Grec
      return GoogleFonts.roboto(
        fontSize: adjustedFontSize,
        fontWeight: fontWeight,
      );
    case 'zh':
      return GoogleFonts.notoSansSc(
        fontSize: adjustedFontSize,
        fontWeight: fontWeight,
      );
    case 'ja':
      return GoogleFonts.notoSansJp(
        fontSize: adjustedFontSize,
        fontWeight: fontWeight,
      );
    case 'ko':
      return GoogleFonts.notoSansKr(
        fontSize: adjustedFontSize,
        fontWeight: fontWeight,
      );
    case 'th':
      return GoogleFonts.notoSansThai(
        fontSize: adjustedFontSize,
        fontWeight: fontWeight,
      );
    default:
      return GoogleFonts.titanOne(
        fontSize: adjustedFontSize,
        fontWeight: fontWeight,
      );
  }
}
