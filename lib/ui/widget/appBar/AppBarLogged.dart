import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

import 'package:vobzilla/logic/blocs/drawer/drawer_bloc.dart';
import 'package:vobzilla/logic/blocs/drawer/drawer_event.dart';
import 'package:vobzilla/ui/widget/appBar/TitleSite.dart';

import '../../../data/models/user_firestore.dart';
import '../../../data/services/localstorage_service.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../../logic/blocs/user/user_bloc.dart';
import '../../../logic/blocs/user/user_state.dart';
import '../../screens/home_screen.dart';

class AppBarLogged extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  AppBarLogged({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TitleSite(),
      key: const ValueKey('appBarKey'),
      elevation: 5,
      shadowColor: Colors.grey,
      actions: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated && state.user != null) {
              final user = state.user!;
              return FutureBuilder<UserFirestore?>(
                  future: LocalStorageService().loadUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Erreur de chargement du profil: ${snapshot.error}"));
                    }
                    if (snapshot.hasData) {
                      final userProfile = snapshot.data!;
                      final String pseudo = userProfile.pseudo;
                      return Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: GestureDetector(
                            onTap: () {
                              context.read<DrawerBloc>().add(OpenSettingsDrawer(context: context));
                              scaffoldKey.currentState!.openEndDrawer();
                            },
                            child: Stack(
                              children: [
                                userProfile.photoURL != ''
                                    ?
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.blue.shade700,
                                      backgroundImage:NetworkImage(userProfile.photoURL),
                                    )
                                    :
                                    Avatar(
                                      radius: 22,
                                      name: _getValidName(pseudo),
                                      fontsize: 28,
                                    ),
                                Positioned(
                                  bottom: 0,
                                  right:0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.menu,
                                      size: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                      );

                    }
                    return const Center(child: CircularProgressIndicator());
                  }
              );
            }

            return const Center(child: CircularProgressIndicator());
            //return SizedBox.shrink();
          },
        ),
      ],
    );
  }

  String _getInitials(String? firstName, String? lastName) {
    final f = firstName?.isNotEmpty == true ? firstName![0] : '';
    final l = lastName?.isNotEmpty == true ? lastName![0] : '';
    return (f + l).toUpperCase();
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


/*
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
                context.read<DrawerBloc>().add(OpenLocalisationDrawer());
                scaffoldKey.currentState!.openEndDrawer();
              },
          ),*/
String _getValidName(String? input) {
  final fallback = '?';
  if (input == null || input.trim().isEmpty) return fallback;

  // Remove invalid characters if necessary
  final clean = input.trim().replaceAll(RegExp(r'[^\w\s]'), '');

  return clean.isEmpty ? fallback : clean;
}
