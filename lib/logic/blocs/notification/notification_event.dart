import 'package:flutter/material.dart';

abstract class NotificationEvent {}

// Événement pour demander l'affichage d'une SnackBar
class ShowNotification extends NotificationEvent {
  final String message;
  final Color backgroundColor;

  ShowNotification({
    required this.message,
    this.backgroundColor = Colors.black,
  });
}

// Événement pour indiquer que la notification a été traitée (optionnel mais propre)
class NotificationDismissed extends NotificationEvent {}
