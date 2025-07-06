import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';

import '../theme/appColors.dart';
import '../backgroundBlueLinear.dart';


class HomeLogoutScreen extends StatelessWidget {
  const HomeLogoutScreen({super.key});
  @override
  Widget build(BuildContext context) {
   return Scaffold(
       body: backgroundBlueLinear(
         context: context,
         child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/brand/logo_landing.png"),
                   // TitleSite(typoSize: 80),
                    Text(context.loc.home_notlogged_accroche1,
                        style: TextStyle(
                            fontSize: 25,
                            fontFamily: GoogleFonts.titanOne().fontFamily)),
                    SizedBox(height: 5),
                    Text(
                        context.loc.home_notlogged_accroche2,
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
                        children:  <TextSpan>[
                          TextSpan(text: context.loc.home_notlogged_accroche3),
                          TextSpan(text: context.loc.home_notlogged_accroche4, style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ", ${context.loc.home_notlogged_accroche5}"),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                        "📈 ${context.loc.home_notlogged_accroche6}",
                        textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                        "🎯 ${context.loc.home_notlogged_accroche7}",
                        textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                        "🧠 ${context.loc.home_notlogged_accroche8}",
                        textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                        context.loc.home_notlogged_accroche9,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                        key: ValueKey('link_home_login'),
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(context.loc.home_notlogged_button_go)
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/featureGraphic');
                        },
                        child: Text("featureGraphic")
                    )
                  ]
              )
            ),
        )

    );
  }
}
