import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'appColors.dart';

Container BackgroundBlueLinear({required Widget child, required BuildContext context}) {
  double widthScreen=MediaQuery.of(context).size.width;
  return Container(
    constraints: BoxConstraints(maxWidth: widthScreen,minWidth:widthScreen, minHeight: MediaQuery.of(context).size.height),
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
    child: child,
  );
}
/*
AppColors.backgroundLanding,
          AppColors.cardBackground,
          AppColors.cardBackground,
          AppColors.cardBackground,
          AppColors.backgroundLanding,
 */
