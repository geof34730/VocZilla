import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mappe "fr", "pt-BR", "zh_Hant", etc. -> ("zh","hant")
(String, String?) _parseLang(String code) {
  final c = code.toLowerCase().replaceAll('_', '-');
  final parts = c.split('-');
  if (parts.isEmpty) return ('', null);
  final lang = parts.first;
  String? sub;
  if (parts.length >= 2) {
    final p1 = parts[1];
    sub = (p1 == 'hans' || p1 == 'hant' || p1 == 'latn' || p1 == 'cyrl')
        ? p1
        : parts.skip(1).join('-');
  }
  return (lang, sub);
}

/// Coups disponibles selon familles utilisées ici
const _notoCjk = <FontWeight>[
  FontWeight.w100, FontWeight.w300, FontWeight.w400,
  FontWeight.w500, FontWeight.w700, FontWeight.w900,
];
const _notoCommon = <FontWeight>[
  FontWeight.w300, FontWeight.w400, FontWeight.w500, FontWeight.w700,
];

FontWeight _heaviest(List<FontWeight> avail) => avail.last;

FontWeight _nearestWeight(FontWeight requested, List<FontWeight> available) {
  FontWeight best = available.first;
  int bestDelta = (requested.index - best.index).abs();
  for (final w in available.skip(1)) {
    final d = (requested.index - w.index).abs();
    if (d < bestDelta) { best = w; bestDelta = d; }
  }
  return best;
}

/// Calibrations pour égaler l'IMPACT visuel de Titan One (taille & “masse”)
/// Retourne (normalScale, boldScale, letterSpacingBold)
({double normal, double bold, double letterSpacingBold}) _calibFor(String lang, String? sub) {
  switch (lang) {
    case 'zh': // Hans/Hant (densité forte)
      return (normal: 0.92, bold: 0.95, letterSpacingBold: -0.05);
    case 'ja':
      return (normal: 0.95, bold: 0.98, letterSpacingBold: -0.05);
    case 'ko':
      return (normal: 0.98, bold: 1.00, letterSpacingBold: -0.05);
    case 'th':
      return (normal: 1.05, bold: 1.08, letterSpacingBold: -0.03);
    case 'ar': // scripts cursifs
    case 'fa':
    case 'ur':
    case 'ps':
      return (normal: 1.12, bold: 1.16, letterSpacingBold: -0.02);
    case 'he':
      return (normal: 1.08, bold: 1.12, letterSpacingBold: -0.02);
  // Grec / cyrillique : proche du latin
    case 'el':
    case 'uk':
    case 'ru':
    case 'bg':
    case 'be':
    case 'kk':
      return (normal: 1.00, bold: 1.06, letterSpacingBold: -0.04);
  // Sous-continent indien (ajustement léger)
    case 'hi':
    case 'mr':
    case 'ne':
    case 'bn':
    case 'pa':
    case 'ta':
    case 'te':
    case 'kn':
    case 'ml':
    case 'gu':
    case 'si':
      return (normal: 1.00, bold: 1.04, letterSpacingBold: -0.02);
  // SEA & autres
    case 'km':
    case 'lo':
    case 'my':
    case 'hy':
    case 'ka':
    case 'am':
    case 'ti':
      return (normal: 1.00, bold: 1.04, letterSpacingBold: -0.02);
    default: // latin (référence Titan One)
      return (normal: 1.00, bold: 1.08, letterSpacingBold: -0.15);
  }
}

/// Faux “bold” discret pour épaissir Titan One (pas de halo)
List<Shadow> _titanOneFauxBoldShadows(double px) => [
  Shadow(offset: Offset( px,  0), blurRadius: 0),
  Shadow(offset: Offset(-px,  0), blurRadius: 0),
  Shadow(offset: Offset( 0,  px), blurRadius: 0),
  Shadow(offset: Offset( 0, -px), blurRadius: 0),
];

TextStyle getFontForLanguage({
  required String codelang,
  double? fontSize,              // ← taille RÉFÉRENCE Titan One
  FontWeight? fontWeight,
  FontStyle? fontStyle,
  double? height,
  Locale? locale,
}) {
  final (lang, sub) = _parseLang(codelang);
  final wantsBold = (fontWeight ?? FontWeight.w400).index >= FontWeight.w700.index;

  // Calibrations “match Titan One”
  final calib = _calibFor(lang, sub);
  final sizeRef = fontSize ?? 16.0;
  final sizeCalib = sizeRef * (wantsBold ? calib.bold : calib.normal);

  // Fallbacks anti-tofu (appliqués via copyWith)
  final fallbacks = <String>[
    GoogleFonts.notoSans().fontFamily!,
    GoogleFonts.roboto().fontFamily!,
    GoogleFonts.notoSansArabic().fontFamily!,
    GoogleFonts.notoSansHebrew().fontFamily!,
    GoogleFonts.notoSansDevanagari().fontFamily!,
    GoogleFonts.notoSansBengali().fontFamily!,
    GoogleFonts.notoSansGurmukhi().fontFamily!,
    GoogleFonts.notoSansTamil().fontFamily!,
    GoogleFonts.notoSansTelugu().fontFamily!,
    GoogleFonts.notoSansKannada().fontFamily!,
    GoogleFonts.notoSansMalayalam().fontFamily!,
    GoogleFonts.notoSansGujarati().fontFamily!,
    GoogleFonts.notoSansSinhala().fontFamily!,
    GoogleFonts.notoSansKhmer().fontFamily!,
    GoogleFonts.notoSansLao().fontFamily!,
    GoogleFonts.notoSansGeorgian().fontFamily!,
    GoogleFonts.notoSansArmenian().fontFamily!,
    GoogleFonts.notoSansEthiopic().fontFamily!,
    GoogleFonts.notoSansMyanmar().fontFamily!,
    GoogleFonts.notoSansJp().fontFamily!,
    GoogleFonts.notoSansKr().fontFamily!,
    GoogleFonts.notoSansSc().fontFamily!,
    GoogleFonts.notoSansTc().fontFamily!,
  ];

  TextStyle _finish(TextStyle base, {
    FontWeight? weight,
    double? letterSpacing,
    bool applyVariations = true,
    List<Shadow>? shadows,
  }) {
    final w = weight ?? fontWeight ?? FontWeight.w400;
    return base.copyWith(
      fontSize: sizeCalib,
      fontWeight: w,
      fontStyle: fontStyle,
      height: height,
      locale: locale,
      letterSpacing: wantsBold ? (letterSpacing ?? 0) : null,
      shadows: shadows,
      fontFamilyFallback: fallbacks,
      // Variation 'wght' (n'a d'effet que si la fonte est variable)
      fontVariations: applyVariations ? [FontVariation('wght', w.value.toDouble())] : null,
    );
  }

  // === scripts non-latins : on “match” Titan One avec coupes réelles + calib ===
  switch (lang) {
  // Arabe + apparentées
    case 'ar':
    case 'fa':
    case 'ur':
    case 'ps': {
      final target = wantsBold ? FontWeight.w700 : FontWeight.w400;
      final eff = _nearestWeight(target, _notoCommon);
      return _finish(
        GoogleFonts.notoSansArabic(),
        weight: eff,
        letterSpacing: calib.letterSpacingBold,
      );
    }

  // Hébreu
    case 'he': {
      final target = wantsBold ? FontWeight.w700 : FontWeight.w400;
      final eff = _nearestWeight(target, _notoCommon);
      return _finish(
        GoogleFonts.notoSansHebrew(),
        weight: eff,
        letterSpacing: calib.letterSpacingBold,
      );
    }

  // Cyrillique (Roboto)
    case 'uk':
    case 'ru':
    case 'bg':
    case 'be':
    case 'kk': {
      final target = wantsBold ? FontWeight.w800 : FontWeight.w400;
      final eff = _nearestWeight(target, _notoCommon);
      return _finish(
        GoogleFonts.roboto(),
        weight: eff,
        letterSpacing: calib.letterSpacingBold,
      );
    }

  // Grec
    case 'el': {
      final target = wantsBold ? FontWeight.w800 : FontWeight.w400;
      final eff = _nearestWeight(target, _notoCommon);
      return _finish(
        GoogleFonts.roboto(),
        weight: eff,
        letterSpacing: calib.letterSpacingBold,
      );
    }

  // CJK (KR/JP/SC/TC) : pousser jusqu’à w900 en “bold” pour masse Titan One
    case 'zh': {
      final target = wantsBold ? FontWeight.w900 : FontWeight.w400;
      final eff = _nearestWeight(target, _notoCjk);
      final style = (sub == 'hant')
          ? GoogleFonts.notoSansTc()
          : GoogleFonts.notoSansSc();
      return _finish(style, weight: eff, letterSpacing: calib.letterSpacingBold, applyVariations: false);
    }
    case 'ja': {
      final target = wantsBold ? FontWeight.w900 : FontWeight.w400;
      final eff = _nearestWeight(target, _notoCjk);
      return _finish(GoogleFonts.notoSansJp(), weight: eff, letterSpacing: calib.letterSpacingBold, applyVariations: false);
    }
    case 'ko': {
      final target = wantsBold ? FontWeight.w900 : FontWeight.w400;
      final eff = _nearestWeight(target, _notoCjk);
      return _finish(GoogleFonts.notoSansKr(), weight: eff, letterSpacing: calib.letterSpacingBold, applyVariations: false);
    }

  // Inde & voisins
    case 'hi':
    case 'mr':
    case 'ne':
    case 'bn':
    case 'pa':
    case 'ta':
    case 'te':
    case 'kn':
    case 'ml':
    case 'gu':
    case 'si': {
      final target = wantsBold ? FontWeight.w700 : FontWeight.w400;
      final eff = _nearestWeight(target, _notoCommon);
      return _finish(
        {
          'hi': GoogleFonts.notoSansDevanagari(),
          'mr': GoogleFonts.notoSansDevanagari(),
          'ne': GoogleFonts.notoSansDevanagari(),
          'bn': GoogleFonts.notoSansBengali(),
          'pa': GoogleFonts.notoSansGurmukhi(),
          'ta': GoogleFonts.notoSansTamil(),
          'te': GoogleFonts.notoSansTelugu(),
          'kn': GoogleFonts.notoSansKannada(),
          'ml': GoogleFonts.notoSansMalayalam(),
          'gu': GoogleFonts.notoSansGujarati(),
          'si': GoogleFonts.notoSansSinhala(),
        }[lang]!,
        weight: eff,
        letterSpacing: calib.letterSpacingBold,
      );
    }

  // SEA & autres
    case 'th':
      return _finish(GoogleFonts.notoSansThai(),
          weight: _nearestWeight(wantsBold ? FontWeight.w700 : FontWeight.w400, _notoCommon),
          letterSpacing: calib.letterSpacingBold);
    case 'km':
      return _finish(GoogleFonts.notoSansKhmer(),
          weight: _nearestWeight(wantsBold ? FontWeight.w700 : FontWeight.w400, _notoCommon),
          letterSpacing: calib.letterSpacingBold);
    case 'lo':
      return _finish(GoogleFonts.notoSansLao(),
          weight: _nearestWeight(wantsBold ? FontWeight.w700 : FontWeight.w400, _notoCommon),
          letterSpacing: calib.letterSpacingBold);
    case 'my':
      return _finish(GoogleFonts.notoSansMyanmar(),
          weight: _nearestWeight(wantsBold ? FontWeight.w700 : FontWeight.w400, _notoCommon),
          letterSpacing: calib.letterSpacingBold);

  // === LATIN : Titan One = référence ; simule le bold pour “même rendu” ===
    default: {
      if (wantsBold) {
        // Simulation de “Titan One Bold”: taille calibrée + serrage + micro-épaisseur
        return GoogleFonts.titanOne(
          fontSize: sizeCalib,
          fontWeight: FontWeight.w400, // Titan One n’a qu’un poids
          fontStyle: fontStyle,
          height: height,
          locale: locale,
        ).copyWith(
          fontFamilyFallback: fallbacks,
          letterSpacing: _calibFor(lang, sub).letterSpacingBold, // -0.15
          shadows: _titanOneFauxBoldShadows(0.25),
        );
      }
      // Normal → Titan One pur, calibré
      return GoogleFonts.titanOne(
        fontSize: sizeCalib,
        fontWeight: FontWeight.w400,
        fontStyle: fontStyle,
        height: height,
        locale: locale,
      ).copyWith(fontFamilyFallback: fallbacks);
    }
  }
}
