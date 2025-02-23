import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/ui/widget/drawer/localisation.dart';
import 'package:vobzilla/ui/widget/drawer/navigation.dart';
import 'package:vobzilla/logic/blocs/drawer/drawer_event.dart';

class DrawerBloc extends Bloc<DrawerEvent, Widget?> {
  DrawerBloc() : super(null) {
    on<OpenMenuDrawer>((event, emit) {
      emit(drawerLocalisation());
    });

    on<OpenSettingsDrawer>((event, emit) {
      emit(drawerNavigation(context: event.context));
    });

    on<CloseDrawer>((event, emit) {
      emit(null); // Ferme le drawer
    });
  }
}
