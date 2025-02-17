import 'package:flutter/material.dart';

import 'site-title.dart';

AppBar appBar({required BuildContext context}) {
  return AppBar(
    title:TitleSite(),
    elevation: 5,
    shadowColor: Colors.grey,
    actions:[
      Text('fr'),
      Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          );
        },
      ),
    ]
  );
}
