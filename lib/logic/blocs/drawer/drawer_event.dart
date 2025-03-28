// drawer_event.dart
import 'package:flutter/material.dart';

abstract class DrawerEvent {}

class OpenLocalisationDrawer extends DrawerEvent {}

class OpenSettingsDrawer extends DrawerEvent {
  final BuildContext context;
  OpenSettingsDrawer({required this.context});
}


