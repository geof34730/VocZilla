import 'package:flutter/cupertino.dart';

import 'appColors.dart';

Container BackgroundBlueLinear({required Widget child}) {
  return Container(
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
    child: child,
  );
}
