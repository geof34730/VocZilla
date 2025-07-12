import 'package:flutter/material.dart';
import 'theme/appColors.dart';

class BackgroundBlueLinear extends StatelessWidget {
  final Widget child;

  const BackgroundBlueLinear({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      height: screenSize.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: [0.1, 0.5, 0.4],
          colors: [
            Colors.white,
            AppColors.cardBackground,
            AppColors.cardBackground,
          ],
        ),
      ),
      child: child,
    );
  }
}
