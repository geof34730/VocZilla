import 'package:flutter/material.dart';
import 'package:vobzilla/ui/theme/appColors.dart';

Drawer drawerLocalisation() {
  return Drawer(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero

    ),
    //width: MediaQuery.of(context).size.width,
    elevation: 5,
    shadowColor: Colors.grey,
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: AppColors.primary,
          ),
          child: Text('Drawer Localisation'),
        ),
        ListTile(
          title: Text('Item 1'),
          onTap: () {
            print("Item 1");
          },
        ),

      ],
    ),
  );
}
