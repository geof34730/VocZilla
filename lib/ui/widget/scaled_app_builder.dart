import 'package:flutter/material.dart';

class ScaledAppBuilder extends StatelessWidget {
  final double designWidth;
  final Widget child;

  const ScaledAppBuilder({
    Key? key,
    required this.designWidth,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return child;
    return LayoutBuilder(
      builder: (context, constraints) {
        double scale = constraints.maxWidth / designWidth;
        if (constraints.maxWidth < designWidth) {
          print("ZOOM positif (shrink)");
          scale=1;
        } else {
          print("ZOOM NEGATIF (zoom)");
          scale=1;
        }
        final double scaledHeight = (constraints.maxHeight / scale);

        return Transform(
          transform: Matrix4.identity()..scale(scale, scale),
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: designWidth,
            height: scaledHeight,
            child: child,
          ),
        );
      },
    );
  }
}
