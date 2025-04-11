import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/data/repository/data_user_repository.dart';
import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/ui/theme/appColors.dart';
import '../../../app_route.dart';
import '../../../core/utils/logger.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../../logic/blocs/user/user_bloc.dart';
import '../../../logic/blocs/user/user_state.dart';
import '../../theme/theme.dart';
import '../elements/DialogHelper.dart';

Drawer DrawerNavigation({required BuildContext context}) {
  return Drawer(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                  if (state is AuthAuthenticated ) {
                    Logger.Yellow.log("*************************rewrite drawer Navigation : ${state.user?.displayName}");
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
                closeDrawer(context);
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
                closeDrawer(context);
                print("mon profil");
              },
              child: Text("Mon profil"),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: InkWell(
              onTap: () {
                closeDrawer(context);
                Navigator.pushNamed(context, '/updateprofile');
              },
              child: Text("Update profile"),
            ),
          ),
          BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserFreeTrialPeriodAndNotSubscribed) {
                  return Column(
                    children: [
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.access_time_filled_outlined, color: Colors.red),
                        title: InkWell(
                          onTap: () {
                            closeDrawer(context);
                            DialogHelper().showFreeTrialDialog(context: context);
                          },
                          child: Text("Ma période d'essai",
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                // Retournez un SizedBox vide pour les autres états
                return SizedBox();
              }
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.subscriptions_rounded),
            title: InkWell(
              onTap: () {
                closeDrawer(context);
                Navigator.pushNamed(context, '${AppRoute.subscription}');
              },
              child: Text(context.loc.my_purchase),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: InkWell(
              onTap: () {
                closeDrawer(context);
                context.read<AuthBloc>().add(SignOutRequested());
              },
              child: Text("Déconnexion"),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: InkWell(
              onTap: () {
                //SubscriptionService().checkAndroidSubscription();
                //UserRepository().updateSubscriptionStatus(true);
              },
              child: Text("UPDATE SUBCRIPTION IN FIREBASE"),
            ),
          ),
        ],
      ),
    ),
  );
}
void closeDrawer(BuildContext context) {
  Navigator.of(context).pop();
}


