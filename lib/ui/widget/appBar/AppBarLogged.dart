import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:vobzilla/logic/blocs/drawer/drawer_bloc.dart';
import 'package:vobzilla/logic/blocs/drawer/drawer_event.dart';
import 'package:vobzilla/ui/widget/appBar/TitleSite.dart';

import '../../../core/utils/string.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_state.dart';

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
            if (state is AuthAuthenticated) {
              final userProfile = state.userProfile;
              final String pseudo = userProfile.pseudo ?? '';
              return Padding(
                padding: const EdgeInsets.only(right: 10,left:10),
                    child:GestureDetector(
                      key: ValueKey('open_drawer_voczilla'),
                      onTap: () {
                        context.read<DrawerBloc>().add(OpenSettingsDrawer(context: context));
                        scaffoldKey.currentState!.openEndDrawer();
                      },
                      child: Stack(

                        children: [
                          userProfile.imageAvatar.isNotEmpty
                              ? CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.blue.shade700,
                                  backgroundImage: MemoryImage(base64Decode(userProfile.imageAvatar)),
                                )
                              : Avatar(
                                radius: 22,
                                name: GetValidName(pseudo),
                                fontsize: 28,
                              ),
                          Positioned(
                            bottom: 0,
                            right: 0,
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
                    ),

              );
            }

            // 3. Si l'état n'est pas AuthAuthenticated (ex: chargement, déconnecté),
            //    on n'affiche rien dans les actions.
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);


}

