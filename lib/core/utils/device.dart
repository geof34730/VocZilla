import 'package:flutter/cupertino.dart';

bool isTablet({required BuildContext context}) {
  final size = MediaQuery.of(context).size;
  final shortestSide = size.shortestSide;

  // Généralement, un device est considéré comme une tablette si sa largeur minimale est >= 600 dp
  return shortestSide >= 600;
}
