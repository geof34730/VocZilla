import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/ui/widget/appBar/appBar.dart';

import '../blocs/drawer/bloc.dart';

Scaffold Layout({required Widget child}) {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  return  Scaffold(
    key: _scaffoldKey,
    appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
    endDrawer: BlocBuilder<DrawerBloc, Widget?>(
      builder: (context, drawer) {
        return drawer ?? SizedBox.shrink(); // Affiche le drawer sélectionné ou rien
      },
    ),
    body: child,
  );

}
