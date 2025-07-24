import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/logic/blocs/user/user_bloc.dart';
import 'package:vobzilla/logic/blocs/user/user_state.dart';
import '../../../app_route.dart';
import '../../../core/utils/getFontForLanguage.dart';
import '../../../core/utils/logger.dart';
import '../../../global.dart';

class DialogHelper {
   Future<void> showFreeTrialDialog({required BuildContext context, int daysLeft = 0}) async {
     Logger.Magenta.log("Show Trial Dialogue ");
      if (context.mounted ) {
        showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                elevation: 5,
                actionsOverflowAlignment: OverflowBarAlignment.center,
                actionsAlignment: MainAxisAlignment.center,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                contentPadding: EdgeInsets.only(top: 10.0),
                title: Text(
                  context.loc.widget_dialogHelper_showfreetrialdialog_description1,
                  textAlign: TextAlign.center,
                  style: getFontForLanguage(
                    codelang: Localizations.localeOf(context).languageCode,
                    fontSize: 18,
                  ),
                ),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, left: 20, right: 20),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: '${context.loc.widget_dialogHelper_showfreetrialdialog_description2} ',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: GoogleFonts
                                  .roboto()
                                  .fontFamily,
                              color: Colors.black,
                              height: 1.2,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '$daysFreeTrial ${context.loc.widget_dialogHelper_showfreetrialdialog_days}',
                                style: getFontForLanguage(
                                  codelang: Localizations.localeOf(context).languageCode,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ).copyWith(
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: " ${context.loc.widget_dialogHelper_showfreetrialdialog_description3}",
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 0, bottom: 0, left: 20, right: 20),
                        child: Text(
                          '${context.loc.widget_dialogHelper_showfreetrialdialog_description4} ${daysLeft} ${context.loc.widget_dialogHelper_showfreetrialdialog_days}',
                          textAlign: TextAlign.center,
                          style: getFontForLanguage(
                            codelang: Localizations.localeOf(context).languageCode,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ).copyWith(
                            height: 1.2,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 0, bottom: 0, left: 20, right: 20),
                        child: Text(
                          context.loc.widget_dialogHelper_showfreetrialdialog_description5,
                          textAlign: TextAlign.center,
                          style: getFontForLanguage(
                            codelang: Localizations.localeOf(context).languageCode,
                            fontSize: 18,
                          ).copyWith(
                            height: 1.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20, bottom: 20, left: 20, right: 20),
                        child: Text(
                          textAlign: TextAlign.center,
                          "${context.loc.widget_dialogHelper_showfreetrialdialog_description6} :",
                          style: TextStyle(
                            height: 1.2,
                            fontSize: 15,
                            fontFamily: GoogleFonts
                                .roboto()
                                .fontFamily,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.pushNamed(dialogContext, AppRoute.subscription);
                    },
                    child: Text(context.loc.button_sabonner),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: Text(context.loc.widget_dialogHelper_showfreetrialdialog_later),
                  ),
                ],
              );
            }
        );
      }
  }
}

