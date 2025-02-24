import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';

import 'package:vobzilla/ui/theme/appColors.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';

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
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                print(state.user);
                return Text(state.user?.displayName ?? '');
              }
              return const Text('');
            },
          ),
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

