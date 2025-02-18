import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'blocs/drawer/bloc.dart';
import 'cubit/localization.dart';

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


