import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/data/repository/user_repository.dart';

import '../../../app_route.dart';
import '../../../global.dart';
import '../../../logic/blocs/user/user_bloc.dart';
import '../../../logic/blocs/user/user_state.dart';

class DialogHelper {
  static Future<void> showPurchaseDialog({required BuildContext context}) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 5,
          actionsOverflowAlignment: OverflowBarAlignment.center,
          actionsAlignment: MainAxisAlignment.center,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          title: Text(
            "Profitez de votre période d’essai gratuite !",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontFamily: GoogleFonts.titanOne().fontFamily,
            ),
          ),
          content: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserOnLeftDaysFreeTrial) {
                int leftDaysFreeTrial = state.daysLeft;
                return SingleChildScrollView(
                  child: ListBody(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text:
                            'Bienvenue ! Vous bénéficiez actuellement d’une période d’essai gratuite de ',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: GoogleFonts.roboto().fontFamily,
                              color: Colors.black,
                              height: 1.2,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '$daysFreeTrial jours',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontFamily:
                                  GoogleFonts.titanOne().fontFamily,
                                ),
                              ),
                              TextSpan(
                                text:
                                " pour découvrir toutes les fonctionnalités de notre application.",
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (leftDaysFreeTrial > 0) ...[
                        Padding(
                          padding: EdgeInsets.only(
                              top: 0, bottom: 0, left: 20, right: 20),
                          child: Text(
                            'Il vous reste',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              height: 1.0,
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: GoogleFonts.titanOne().fontFamily,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 0, bottom: 0, left: 20, right: 20),
                          child: Text(
                            '$leftDaysFreeTrial jours',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              fontSize: 22,
                              fontFamily: GoogleFonts.titanOne().fontFamily,
                            ),
                          ),
                        ),
                      ],
                      if (leftDaysFreeTrial == 0) ...[
                        Padding(
                          padding: EdgeInsets.only(top: 0, bottom: 0, left: 20, right: 20),
                          child: Text(
                            "C'est votre dernier jour",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              fontSize: 18,
                              fontFamily: GoogleFonts.titanOne().fontFamily,
                            ),
                          ),
                        ),
                      ],
                      Padding(
                        padding: EdgeInsets.only(top: 0, bottom: 0, left: 20, right: 20),
                        child: Text(
                          'd’essai gratuits',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.0,
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: GoogleFonts.titanOne().fontFamily,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
                        child: Text(
                          textAlign: TextAlign.center,
                          "Ne laissez pas votre expérience s’interrompre ! Choisissez l’abonnement qui vous convient et continuez à profiter sans interruption :",
                          style: TextStyle(
                            height: 1.2,
                            fontSize: 15,
                            fontFamily: GoogleFonts.roboto().fontFamily,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is FreeTrialExpired) {
                return Text("Votre période d'essai a expiré.");
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoute.subscription);
              },
              child: Text("S'abonner"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Plus tard"),
            ),
          ],
        );
      },
    );
  }
}
