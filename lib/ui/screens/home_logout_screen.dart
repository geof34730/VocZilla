import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';

import '../theme/backgroundBlueLinear.dart';


class HomeLogoutScreen extends StatelessWidget {
  const HomeLogoutScreen({super.key});
  @override
  Widget build(BuildContext context) {
   return Scaffold(
        body:  SingleChildScrollView(
        child:BackgroundBlueLinear(
              context: context,
              child:Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/brand/logo_landing.png"),
                   // TitleSite(typoSize: 80),
                    Text("Booste ton anglais !",
                        style: TextStyle(
                            fontSize: 25,
                            fontFamily: GoogleFonts.titanOne().fontFamily)),
                    SizedBox(height: 5),
                    Text(
                        "Tu veux enrichir ton vocabulaire anglais ?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,

                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: 14,
                        ),
                        children: const <TextSpan>[
                          TextSpan(text: 'Accède à '),
                          TextSpan(text: '5 600 mots essentiels', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ", triés par fréquence d'utilisation pour apprendre les mots qui comptent vraiment."),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                        "📈 Méthode rapide et efficace",
                        textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                        "🎯 Apprends les mots les plus utiles en priorité",
                        textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                        "🧠 Mémorisation optimisée pour progresser vite",
                        textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                        "Prêt à dominer la langue de Shakespeare ? ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text("C'est parti !")
                    )
                  ]
              )
            ),
        )
        )
    );
  }
}
