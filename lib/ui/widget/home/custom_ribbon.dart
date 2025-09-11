import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomRibbon extends StatelessWidget {
  final Widget child;
  final Widget title;
  final Color color;

  const CustomRibbon({
    Key? key,
    required this.child,
    required this.title,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect( // Ceci "coupe" les parties du ruban qui dépassent de la carte
      child: Stack(
        children: [
          child,
          Positioned(
            top: 12, // Position verticale du ruban
            left: -34, // On ancre à gauche au lieu de droite
            child: Transform.rotate(
              angle: -math.pi / 4, // On inverse l'angle de rotation (-45 degrés)
              alignment: Alignment.center,
              child: Container(
                height: 15, // Hauteur du ruban
                width: 110, // Largeur du ruban
                color: color,
                child: Center(
                  child: title,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
