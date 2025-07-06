import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'appColors.dart';

Container backgroundBlueLinear(
    {required Widget child, required BuildContext context}) {


  double widthScreen = MediaQuery.of(context).size.width;
  double heightScreen = MediaQuery.of(context).size.height;
  return Container(
      constraints: BoxConstraints(
          maxWidth: widthScreen, minWidth: widthScreen, minHeight: heightScreen, maxHeight: heightScreen),
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [
              0.1,
              0.5,
              0.4
            ],
            colors: [
              Colors.white,
              AppColors.cardBackground,
              AppColors.cardBackground,
            ],
          )
      ),
    child: SizedBox(
      height: heightScreen, // <-- Contraint le scrollview à la hauteur de l'écran
      child: SingleChildScrollView(
        key: ValueKey('scrollBackgroundBlueLinear'),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: heightScreen,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: child),
            ],
          ),
        ),
      ),
    ),
  );
}
/*
AppColors.backgroundLanding,
          AppColors.cardBackground,
          AppColors.cardBackground,
          AppColors.cardBackground,
          AppColors.backgroundLanding,
 */
