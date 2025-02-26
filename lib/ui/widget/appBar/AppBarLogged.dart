import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vobzilla/logic/blocs/drawer/drawer_bloc.dart';
import 'package:vobzilla/logic/blocs/drawer/drawer_event.dart';
import 'package:vobzilla/ui/widget/appBar/TitleSite.dart';


class AppBarLogged extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  AppBarLogged({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title:TitleSite(),
        elevation: 5,
        shadowColor: Colors.grey,
        actions:[
          InkWell( // Add
              child:Padding(
                  padding: EdgeInsets.only(right: 5),
                  child:Text(
                    Localizations.localeOf(context).languageCode,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
              ),
            onTap: () {
                context.read<DrawerBloc>().add(OpenMenuDrawer());
                scaffoldKey.currentState!.openEndDrawer();
              },
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              context.read<DrawerBloc>().add(OpenSettingsDrawer(context: context));
              scaffoldKey.currentState!.openEndDrawer();
            },
          )
        ]
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}



