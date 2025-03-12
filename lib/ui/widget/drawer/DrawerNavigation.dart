import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:vobzilla/data/repository/data_user_repository.dart';
import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/ui/theme/appColors.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../theme/theme.dart';

Drawer DrawerNavigation({required BuildContext context}) {
  return Drawer(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    //width: MediaQuery.of(context).size.width,
    elevation: 5,
    shadowColor: Colors.grey,
    child: ListTileTheme(
      data: VobdzillaTheme.drawerNavigationListTileTheme,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 160.0,
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: AppColors.primary,
              ),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    return Column(children: [
                      dataUserRepository.getPhotoURL() != ''
                          ? ProfilePicture(
                              name: state.user?.displayName ?? '',
                              radius: 31,
                              fontsize: 21,
                              img: dataUserRepository.getPhotoURL().toString())
                          : ProfilePicture(
                              name: state.user?.displayName ?? '',
                              radius: 31,
                              fontsize: 21,
                            ),
                      Text(
                        state.user?.displayName ?? '',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(state.user?.email ?? ''),
                    ]);
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.show_chart),
            title: InkWell(
              onTap: () {
                print("statistiques");
              },
              child: Text("Mes statistiques"),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: InkWell(
              onTap: () {
                print("mon profil");
              },
              child: Text("Mon profil"),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: InkWell(
              onTap: () {
                context.read<AuthBloc>().add(SignOutRequested());
              },
              child: Text("Déconnexion"),
            ),
          ),
          Divider(),
        ],
      ),
    ),
  );
}

class AuthLogoutRequested {}
