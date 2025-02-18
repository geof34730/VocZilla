import 'package:flutter/material.dart';
import 'package:vobzilla/screens/home.dart';
import 'package:vobzilla/ui/theme/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/drawer/bloc.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: VobdzillaTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => DrawerBloc(),
        child: HomeScreen(),
      ),
    );
  }
}


