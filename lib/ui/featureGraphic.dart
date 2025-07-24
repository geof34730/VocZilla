import 'package:flutter/material.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/ui/theme/appColors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../core/utils/getFontForLanguage.dart';

class FeatureGraphic extends StatelessWidget {
  const FeatureGraphic({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 1024,
          minHeight: 500,
          maxWidth: 1024,
          maxHeight: 500,
        ),
        child: Container(
          width: 1024,
          height: 500,
          color: const Color(0xFF7DECF7),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Logo and title
              Row(
                children: [
                  Image.asset(
                    'assets/brand/logo_featureGraphic.png',
                    width: 200,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: AutoSizeText(
                      context.loc.app_feature_graphic_title,
                      style: getFontForLanguage(
                        codelang: Localizations.localeOf(context).languageCode,
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                      ).copyWith(
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                      maxLines: 2,
                      minFontSize: 16,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Headline
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Colonne des features
                    SizedBox(
                      width: 550,

                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          FeatureItem(
                            icon: Icons.check_circle,
                            text: context.loc.app_feature_graphic_FeatureItem1,
                          ),
                          const SizedBox(height: 25),
                          FeatureItem(
                            icon: Icons.quiz,
                            text: "${context.loc.app_feature_graphic_FeatureItem2}",
                          ),
                          const SizedBox(height: 25),
                          FeatureItem(
                            icon: Icons.show_chart,
                            text: "${context.loc.app_feature_graphic_FeatureItem3}",
                          ),
                          const SizedBox(height: 25),
                          FeatureItem(
                            icon: Icons.list_alt,
                            text: "${context.loc.app_feature_graphic_FeatureItem4}",
                          ),
                        ],
                      ),
                    ),
                    // Espaceur pour pousser l'image à droite
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          'assets/brand/featureGraphic_mobile.png',
                          height: 325,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureItem({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 550, // largeur fixe
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.black87,
            size: 35,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AutoSizeText(
              text,
              style: GoogleFonts.roboto(
                fontSize: 30,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
              maxLines: 2,
              minFontSize: 30,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
