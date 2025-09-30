import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/logic/blocs/user/user_bloc.dart';
import 'package:voczilla/logic/blocs/user/user_state.dart';
import '../../../app_route.dart';
import '../../../core/utils/getFontForLanguage.dart';
import '../../../core/utils/logger.dart';
import '../../../global.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';
class DialogHelper {
  Future<void> showSubscriptionBanner({required BuildContext context}) async {
    Logger.Magenta.log("Show Subscription Dialogue");

    if (!context.mounted) return;

    // Titres en rotation aléatoire
    final titles = [
      "🙈 ${context.loc.subscription_title_1}",
      "🎯 ${context.loc.subscription_title_2}",
      "😅 ${context.loc.subscription_title_3}",
      "🚫 ${context.loc.subscription_title_4}",
      "🤔 ${context.loc.subscription_title_5}",
      "⏰ ${context.loc.subscription_title_6}",
      "🎥 ${context.loc.subscription_title_7}",
      "⏭️ ${context.loc.subscription_title_8}",
    ];
    final randomTitle = titles[Random().nextInt(titles.length)];

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          backgroundColor: scheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // En-tête
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          randomTitle,
                          textAlign: TextAlign.center,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sous-titre
                  Text(
                    "${context.loc.subscription_description1}\n"
                    "${context.loc.subscription_description2}",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withOpacity(.85),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Avantages
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withOpacity(.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    child: Column(
                      children:  [
                        _BenefitRow(text: context.loc.subscription_benefit_zero_pub),
                        SizedBox(height: 8),
                        _BenefitRow(text: context.loc.subscription_navigation_more_speed),
                        SizedBox(height: 8),
                        _BenefitRow(text: context.loc.subscription_max_concentration),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // CTA principal
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 1.5,
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Navigator.pushNamed(dialogContext, AppRoute.subscription);
                      },
                      icon: const Icon(Icons.star_rounded),
                      label:  Text(context.loc.subscription_go_premium),
                    ),
                  ),

                  // Lien secondaire
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      context.loc.subscription_go_with_pub,
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> dialogBuilderShare({required BuildContext context, required String guidListPerso }){
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          //  scrollDirection: Axis.vertical,
            child: AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 10),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 20, horizontal: 10),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              icon: Column(mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(
                          Icons.close,
                        ))
                  ]),
              title: Text(
                context.loc.share_dialogue_builder_title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.00),
              ),
              content: Column(mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 360,

                        child: Text(
                          context.loc.share_dialogue_builder_description_qrcode,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14.00),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.00, bottom: 10.0),
                      child: Container(
                          width: 280,
                          height: 280,
                          color: Colors.blue,
                          child: QrImageView(
                            data: "https://links.voczilla.com/share/$guidListPerso",
                            version: 10,
                            size: 280,
                            gapless: true,
                            backgroundColor: Colors.white,
                          )),
                    ),
                    const Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          'OU',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18.00, fontWeight: FontWeight.bold),
                        )),
                    SizedBox(
                      width: 360,
                      child: Text(
                        context.loc.share_dialogue_builder_description_copy_url,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.00),
                      ),
                    ),
                    SizedBox(
                        width: 360,
                        child: Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                            text: "https://links.voczilla.com/share/$guidListPerso"),
                                      );
                                    },
                                    child: Text(
                                      "https://links.voczilla.com/share/${guidListPerso
                                          .substring(0, 5)}...",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12.00,
                                        color: Colors.blue,
                                        decoration: TextDecoration
                                            .underline, // Optionnel : pour montrer que c'est cliquable
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                            text: "https://links.voczilla.com/share/$guidListPerso"),
                                      );
                                    },
                                  ),
                                ]
                            )
                        )
                    )
                  ]
              ),
            ));
      },
    );
  }


}
class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_rounded, size: 22, color: Colors.green.shade600),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
