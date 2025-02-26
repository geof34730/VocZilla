import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/ui/widget/drawer/DrawerLocalisation.dart';
import 'package:vobzilla/ui/widget/drawer/DrawerNavigation.dart';
import 'package:vobzilla/logic/blocs/drawer/drawer_event.dart';

class DrawerBloc extends Bloc<DrawerEvent, Widget?> {
  DrawerBloc() : super(null) {
    on<OpenMenuDrawer>((event, emit) {
      emit(DrawerLocalisation());
    });

    on<OpenSettingsDrawer>((event, emit) {
      emit(DrawerNavigation(context: event.context));
    });

    on<CloseDrawer>((event, emit) {
      emit(null); // Ferme le drawer
    });
  }
}
