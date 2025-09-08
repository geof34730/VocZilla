import 'package:flutter/material.dart';
import 'package:voczilla/ui/widget/appBar/TitleSite.dart';


class AppBarNotLogged extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  AppBarNotLogged({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title:TitleSite(),
        actions:[
          InkWell( // Add
            child:Padding(
                padding: EdgeInsets.only(right: 15),
                child:Text(
                  Localizations.localeOf(context).languageCode,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
            ),
            onTap: () {
              scaffoldKey.currentState?.openEndDrawer();
            },
          ),

        ]
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
