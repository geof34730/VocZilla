import 'package:flutter/material.dart';

abstract class NotificationState {}

// État initial, aucune notification à afficher
class NotificationInitial extends NotificationState {}

// État indiquant qu'une notification est prête à être affichée
class NotificationVisible extends NotificationState {
  final String message;
  final Color backgroundColor;
  final int timestamp; // Pour s'assurer que même les messages identiques sont uniques

  NotificationVisible({
    required this.message,
    required this.backgroundColor,
  }) : timestamp = DateTime.now().millisecondsSinceEpoch;
}
