import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/ui/theme/appColors.dart';

import '../../layout.dart';



class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Layout(
        child:Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment(1, 1),
              colors: <Color>[
                AppColors.backgroundLanding,
                AppColors.cardBackground,
                AppColors.cardBackground,
                AppColors.cardBackground,

                AppColors.backgroundLanding,
              ],  tileMode: TileMode.mirror,
            ),
          ),
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    SizedBox(height: 15),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text("S'inscrire")
                    )
                  ]
              )
          ),
        )
    );
  }
}
