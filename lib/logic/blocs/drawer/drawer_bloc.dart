import 'package:flutter_bloc/flutter_bloc.dart';
import 'drawer_event.dart';
import 'drawer_state.dart';

class DrawerBloc extends Bloc<DrawerEvent, DrawerState> {
  DrawerBloc() : super(LocalisationDrawerState()) {
    on<OpenLocalisationDrawer>((event, emit) {
      emit(LocalisationDrawerState());
    });

    on<OpenSettingsDrawer>((event, emit) {
      emit(SettingsDrawerState());
    });
  }
}
