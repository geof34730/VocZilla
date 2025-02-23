import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';

import 'package:vobzilla/ui/theme/appColors.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../logic/blocs/auth/auth_event.dart';

Drawer drawerNavigation({required BuildContext context}) {
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
          child: Text('Drawer Header'),
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: InkWell(
            onTap: () {
              context.read<AuthBloc>().add(SignOutRequested());


            },
            child: Text("Déconnexion"),
          ),
        ),
      ],
    ),
  );
}

class AuthLogoutRequested {
}

