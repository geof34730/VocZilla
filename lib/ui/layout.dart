import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/logic/blocs/auth/auth_state.dart';
import 'package:vobzilla/logic/blocs/drawer/drawer_bloc.dart';
import 'package:vobzilla/ui/widget/appBar/AppBarLogged.dart';
import 'package:vobzilla/ui/widget/appBar/AppBarNotLogged.dart';

class Layout extends StatelessWidget {
  final Widget child;

  Layout({required this.child});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AuthAppBar(scaffoldKey: _scaffoldKey),
      endDrawer: BlocBuilder<DrawerBloc, Widget?>(
        builder: (context, drawer) {
          return drawer ?? SizedBox.shrink(); // Affiche le drawer sélectionné ou rien
        },
      ),
      body: Column(
        children: [
          TextLogged(scaffoldKey: _scaffoldKey),
          Expanded(

            child: child,
          ),
        ],
      ),
    );
  }
}

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  AuthAppBar({required this.scaffoldKey});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return AppBarLogged(scaffoldKey: scaffoldKey);
        } else {
          return AppBarNotLogged(scaffoldKey: scaffoldKey);
        }
      },
    );
  }
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class TextLogged extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  TextLogged({required this.scaffoldKey});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Padding(
              padding:EdgeInsets.only(top: 200.00),
              child:Text("logged")
        );
        } else {
          return Text("not logged");
        }
      },
    );
  }
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
