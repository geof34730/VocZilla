import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app_route.dart';
import '../../../logic/blocs/purchase/purchase_bloc.dart';
import '../../../logic/blocs/purchase/purchase_event.dart';
import '../../../logic/blocs/purchase/purchase_state.dart';


class DialogHelper {
  static  Future<void> showPurchaseDialog({required BuildContext context}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 5,
          actionsOverflowAlignment: OverflowBarAlignment.center,
          actionsAlignment: MainAxisAlignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)
              )
          ),
          contentPadding: EdgeInsets.only(top: 10.0),
          title: Text("Profitez de votre période d’essai gratuite !",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: GoogleFonts.titanOne().fontFamily
              )
          ),
          content: BlocBuilder<PurchaseBloc, PurchaseState>(
            builder: (context, state) {
              if (state is ProductsLoaded) {
                return SingleChildScrollView(
                  child: ListBody(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10,bottom: 10,left:20, right: 20),
                          child:RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: 'Bienvenue ! Vous bénéficiez actuellement d’une période d’essai gratuite de ',
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: GoogleFonts.roboto().fontFamily,
                                color: Colors.black,
                                height: 1.2,

                              ),
                              children:  <TextSpan>[
                                TextSpan(text: '7 jours',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontFamily: GoogleFonts.titanOne().fontFamily
                                    )
                                ),
                                TextSpan(text: " pour découvrir toutes les fonctionnalités de notre application."),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 0,bottom: 0,left:20, right: 20),
                          child:Text('Il vous reste',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                height: 1.0,
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: GoogleFonts.titanOne().fontFamily
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 0,bottom: 0,left:20, right: 20),
                          child:Text('6 jours',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  height: 1.2,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 22,
                                  fontFamily: GoogleFonts.titanOne().fontFamily

                              )
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 0,bottom: 0,left:20, right: 20),
                          child:Text('d’essai gratuits',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                height: 1.0,
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: GoogleFonts.titanOne().fontFamily
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 20,bottom: 20,left:20, right: 20),
                            child:Text(
                              textAlign: TextAlign.center,
                              "Ne laissez pas votre expérience s’interrompre ! Choisissez l’abonnement qui vous convient et continuez à profiter sans interruption :",
                              style: TextStyle(
                                  height: 1.2,
                                  fontSize: 15,
                                  fontFamily: GoogleFonts.roboto().fontFamily,
                                  color: Colors.black
                              ),
                            )
                        ),
                      ]
                  ),
                );
              } else if (state is PurchaseFailure) {
                return Text('Erreur: ${state.error}');
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
              child: Text("S'abonner maintenant"),
            ),
            TextButton(
              onPressed: () {
                // Action pour plus tard
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
