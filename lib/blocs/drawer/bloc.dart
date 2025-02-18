import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../ui/widget/drawer/localisation.dart';
import '../../ui/widget/drawer/navigation.dart';
import 'event.dart';

class DrawerBloc extends Bloc<DrawerEvent, Widget?> {
  DrawerBloc() : super(null) {
    on<OpenMenuDrawer>((event, emit) {
      emit(drawerLocalisation());
    });

    on<OpenSettingsDrawer>((event, emit) {
      emit(drawerNavigation());
    });

    on<CloseDrawer>((event, emit) {
      emit(null); // Ferme le drawer
    });
  }
}
