import 'package:flutter/material.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../core/utils/getFontForLanguage.dart';

class FeatureGraphicVoczillaCom extends StatelessWidget {
  const FeatureGraphicVoczillaCom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 1200,
          minHeight: 630,
          maxWidth: 1200,
          maxHeight: 630,
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
                    width: 250,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: AutoSizeText(
                      context.loc.app_feature_graphic_title,
                      style: getFontForLanguage(
                        codelang: Localizations.localeOf(context).languageCode,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ).copyWith(
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                      maxLines: 2,
                      minFontSize: 16,
                      textAlign: TextAlign.center,
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
                    SizedBox(
                      width: 600,
                      // ✅ SOLUTION : Envelopper la colonne dans un SingleChildScrollView.
                      // Cela garantit que même si le contenu est très long (par exemple,
                      // dans une autre langue), il n'y aura jamais d'erreur d'overflow.
                      // Le contenu deviendra simplement scrollable, ce qui est parfait
                      // pour la génération d'une capture d'écran statique.
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(), // Empêche le rebond visuel
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // S'adapte à la taille du contenu
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FeatureItem(
                              icon: Icons.check_circle,
                              text: context.loc.app_feature_graphic_FeatureItem1,
                            ),
                            const SizedBox(height: 20),
                            FeatureItem(
                              icon: Icons.quiz,
                              // 💅 AMÉLIORATION : Utilisation de la vraie valeur, sans la répétition de test.
                              text: context.loc.app_feature_graphic_FeatureItem2,
                            ),
                            const SizedBox(height: 20),
                            FeatureItem(
                              icon: Icons.show_chart,
                              text: context.loc.app_feature_graphic_FeatureItem3,
                            ),
                            const SizedBox(height: 20),
                            FeatureItem(
                              icon: Icons.list_alt,
                              text: context.loc.app_feature_graphic_FeatureItem4,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(padding: EdgeInsets.only(top:20),
                                  child:Image.asset(
                                    'assets/png/button_android.png',
                                    height: 80,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Padding(padding: EdgeInsets.only(top:20),
                                  child:Image.asset(
                                    'assets/png/button_ios.png',
                                    height: 80,
                                  ),
                                )
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                    // Espaceur pour pousser l'image à droite
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          'assets/brand/featureGraphic_mobile.png',
                          height: 400,
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
            size: 45,
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
              // ✅ AMÉLIORATION : Permettre au texte de devenir plus petit
              // si nécessaire pour éviter les coupures.
              minFontSize: 14, // Auparavant 30, ce qui était trop restrictif.
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
