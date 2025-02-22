import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vobzilla/logic/blocs/drawer/drawer_bloc.dart';
import 'package:vobzilla/ui/widget/appBar/AppBarLogged.dart';
import 'package:vobzilla/ui/widget/appBar/AppBarNotLogged.dart';

Scaffold Layout({required Widget child}) {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  return  Scaffold(
    key: _scaffoldKey,
    extendBodyBehindAppBar: true,
    backgroundColor: Colors.transparent,
    appBar: AppBarNotLogged(scaffoldKey: _scaffoldKey),
    endDrawer: BlocBuilder<DrawerBloc, Widget?>(
      builder: (context, drawer) {
        return drawer ?? SizedBox.shrink(); // Affiche le drawer sélectionné ou rien
      },
    ),
    body: child,
  );

}
