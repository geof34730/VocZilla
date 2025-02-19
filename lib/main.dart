import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/app.dart';
import 'package:vobzilla/logic/blocs/drawer/drawer_bloc.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pour SharedPreferences
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => DrawerBloc()),
        BlocProvider(create: (context) => LocalizationCubit()), // Gère la langue
      ],
      child: MyApp(),
    ),
  );
}


