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

class DialogHelper {
   /*Future<void> showFreeTrialDialog({required BuildContext context, int daysLeft = 0}) async {
     Logger.Magenta.log("Show Trial Dialogue ");
      if (context.mounted ) {
        showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                elevation: 5,
                actionsOverflowAlignment: OverflowBarAlignment.center,
                actionsAlignment: MainAxisAlignment.center,
                shape: RoundedRectangleBorder( borderRadius: BorderRadius.all(Radius.circular(20.0))),
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
                        padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
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
                        padding: EdgeInsets.only(top: 0, bottom: 0, left: 20, right: 20),
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
                        padding: EdgeInsets.only( top: 20, bottom: 20, left: 20, right: 20),
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
  }*/


   Future<void> dialogBuilderShare({required BuildContext context,required String guidListPerso }) {
     return showDialog<void>(
       context: context,
       builder: (BuildContext context) {
         return SingleChildScrollView(
           //  scrollDirection: Axis.vertical,
             child: AlertDialog(
               insetPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
               contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
               clipBehavior: Clip.antiAliasWithSaveLayer,
               icon: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end, children: [
                 InkWell(
                     onTap: () {
                       Navigator.of(context).pop();
                     },
                     child: const Icon(
                       Icons.close,
                     ))
               ]),
               title:  Text(
                 context.loc.share_dialogue_builder_title,
                 textAlign: TextAlign.center,
                 style: TextStyle(fontSize: 18.00),
               ),
               content: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
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
                       style: TextStyle(fontSize: 18.00, fontWeight: FontWeight.bold),
                     )),
                SizedBox(
                     width: 360,
                     child:Text(
                       context.loc.share_dialogue_builder_description_copy_url,
                       textAlign: TextAlign.center,
                       style: TextStyle(fontSize: 14.00),
                     ),
                 ),
               SizedBox(
                   width: 360,
                   child:Padding(
                       padding: const EdgeInsets.only(top: 0.0),
                       child:Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                         GestureDetector(
                           onTap: () {
                             Clipboard.setData(
                               ClipboardData(text: "https://links.voczilla.com/share/$guidListPerso"),
                             );

                           },
                           child: Text(
                             "https://links.voczilla.com/share/${guidListPerso.substring(0,5)}...",
                             textAlign: TextAlign.center,
                             style: TextStyle(
                               fontSize: 12.00,
                               color: Colors.blue,
                               decoration: TextDecoration.underline, // Optionnel : pour montrer que c'est cliquable
                             ),
                           ),
                         ),
                         IconButton(
                           icon: const Icon(Icons.copy),
                           onPressed: () {
                             Clipboard.setData(
                               ClipboardData(text: "https://links.voczilla.com/share/$guidListPerso"),
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
