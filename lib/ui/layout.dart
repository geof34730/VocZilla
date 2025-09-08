import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart' hide NavigationDrawer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voczilla/logic/blocs/auth/auth_bloc.dart';
import 'package:voczilla/logic/blocs/auth/auth_state.dart';
import 'package:voczilla/ui/widget/appBar/AppBarLogged.dart';
import 'package:voczilla/ui/widget/appBar/AppBarNotLogged.dart';
import 'package:voczilla/ui/widget/bottomNavigationBar/BottomNavigationBarVocabulary.dart';
import 'package:voczilla/ui/widget/drawer/DrawerNavigation.dart';
import 'package:voczilla/ui/widget/elements/debug.dart';
import 'package:voczilla/ui/widget/home/TitleWidget.dart';

import '../global.dart';
import '../logic/blocs/notification/notification_bloc.dart';
import '../logic/blocs/notification/notification_event.dart';
import '../logic/blocs/notification/notification_state.dart';

class Layout extends StatefulWidget {
  const Layout({
    Key? key,
    required this.child,
    this.appBarNotLogged = false,
    this.showBottomNavigationBar = false,
    this.logged = true,
    this.itemSelected = 0,
    this.id = "0",
    this.titleScreen = null,
  }) : super(key: key);

  final bool appBarNotLogged;
  final bool logged;
  final bool showBottomNavigationBar;
  final dynamic child;
  final int itemSelected;
  final String id;
  final String? titleScreen;

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AuthAppBar(scaffoldKey: _scaffoldKey, appBarNotLogged: widget.appBarNotLogged),
      endDrawer: const NavigationDrawer(),
      floatingActionButton: (debugMode ? FloatingActionButton(
          elevation: 15,
          backgroundColor: Colors.red,
          onPressed: (){
            showDialog(
                context: context,
                builder: (BuildContext context){
                  return DebugWidget();
                }
            );
          },
          child:Text(
            'DEBUG GEOF',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.bold
            ),
          )
      ) : null),
      bottomNavigationBar: (widget.showBottomNavigationBar) ? BottomNavigationBarVocabulary(itemSelected: widget.itemSelected, local: Localizations.localeOf(context).languageCode) : null,
      body:SingleChildScrollView(
          child:Padding(
              padding: widget.logged ? EdgeInsets.only(top: kToolbarHeight + MediaQuery.of(context).padding.top + 20,left:10,right:10,bottom:20) : EdgeInsets.all(0) ,
              child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(widget.titleScreen != null)...[
                    Padding(
                    padding: EdgeInsets.only(bottom: 8),
                      child:titleWidget(text:widget.titleScreen!,codelang: Localizations.localeOf(context).languageCode)
                    )
                  ],
                  widget.child,
                ],
              )
            )
      )

    );
    }
}

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool appBarNotLogged;
  AuthAppBar({required this.scaffoldKey, required this.appBarNotLogged});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if(appBarNotLogged){
          return AppBarNotLogged(scaffoldKey: scaffoldKey);
        }
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
