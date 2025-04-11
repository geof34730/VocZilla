import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/logic/blocs/auth/auth_state.dart';
import 'package:vobzilla/logic/blocs/drawer/drawer_bloc.dart';
import 'package:vobzilla/ui/widget/appBar/AppBarLogged.dart';
import 'package:vobzilla/ui/widget/appBar/AppBarNotLogged.dart';
import 'package:vobzilla/ui/widget/bottomNavigationBar/BottomNavigationBarVocabulary.dart';

import 'package:vobzilla/core/utils/ui.dart';

class Layout extends StatelessWidget {
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
  Widget build(BuildContext context) {

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AuthAppBar(scaffoldKey: scaffoldKey, appBarNotLogged: appBarNotLogged),
      endDrawer: BlocBuilder<DrawerBloc, Widget?>(
        builder: (context, drawer) {
          return drawer ?? Container();
        },
      ),
      bottomNavigationBar: (showBottomNavigationBar) ? BottomNavigationBarVocabulary(itemSelected: itemSelected,id:id) : null,
      body:SingleChildScrollView(
          child:Padding(
              padding: logged ? EdgeInsets.only(top: kToolbarHeight+50,left:10,right:10,bottom:20) : EdgeInsets.all(0) ,
              child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(titleScreen != null)...[
                    Text(titleScreen!,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.titanOne().fontFamily
                      ),
                    ),
                  ],
                  child,
                  /*
                  FutureBuilder<String>(
                    future: getAppVersion(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Center(child:Text('Erreur lors de la récupération du numéro de build',style: TextStyle(color: Colors.red)));
                      } else {
                        return Center(child:Text('Version : ${snapshot.data}',style: TextStyle(color:Colors.grey),));
                      }
                    },
                  ),
                  FutureBuilder<String>(
                    future: getPackageName(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Center(child:Text('Erreur lors de la récupération du numéro de build',style: TextStyle(color: Colors.red)));
                      } else {
                        return Center(child:Text('name : ${snapshot.data}',style: TextStyle(color:Colors.grey),));
                      }
                    },
                  )
                  */
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
