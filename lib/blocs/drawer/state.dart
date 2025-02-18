import 'package:flutter/material.dart';

abstract class DrawerState {}

class DrawerClosed extends DrawerState {}

class DrawerMenuOpened extends DrawerState {
  final Widget drawerContent;
  DrawerMenuOpened(this.drawerContent);
}
