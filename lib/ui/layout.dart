import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/logic/blocs/auth/auth_state.dart';
import 'package:vobzilla/logic/blocs/drawer/drawer_bloc.dart';
import 'package:vobzilla/ui/widget/appBar/AppBarLogged.dart';
import 'package:vobzilla/ui/widget/appBar/AppBarNotLogged.dart';
import 'package:vobzilla/ui/widget/bottomNavigationBar/BottomNavigationBarVocabulary.dart';


import 'package:vobzilla/ui/widget/drawer/DrawerNavigation.dart';
import 'package:vobzilla/ui/widget/elements/debug.dart';
import 'package:vobzilla/ui/widget/home/TitleWidget.dart';

import '../global.dart';
import '../logic/blocs/drawer/drawer_state.dart';
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
      endDrawer: BlocBuilder<DrawerBloc, DrawerState>(
        builder: (context, state) {
         if (state is SettingsDrawerState) {
            return DrawerNavigation(context: context);
          }
          return Container(); // État par défaut ou vide
        },
      ),
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
      bottomNavigationBar: (widget.showBottomNavigationBar) ? BottomNavigationBarVocabulary(itemSelected: widget.itemSelected) : null,
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
