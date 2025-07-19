import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';
import 'package:vobzilla/data/repository/data_user_repository.dart';
import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/logic/blocs/user/user_bloc.dart';
import 'package:vobzilla/logic/blocs/user/user_state.dart';
import 'package:vobzilla/ui/theme/appColors.dart';
import 'package:vobzilla/ui/widget/drawer/trial_period_tile.dart';
import 'package:vobzilla/ui/widget/drawer/voczilla_tile.dart';
import '../../../app_route.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/user_firestore.dart';
import '../../../data/services/localstorage_service.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../theme/theme.dart';
import '../elements/DialogHelper.dart';

// === DRAWER NAVIGATION ===

Drawer DrawerNavigation({
  required BuildContext context,
  String selectedLang = 'fr',
  void Function(String)? onLanguageChanged,
}) {
  return Drawer(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    elevation: 5,
    child: Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ===== HEADER =====
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.cyan[200]),
            child:BlocBuilder<AuthBloc, AuthState>(
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
                                final String displayName = "${userProfile.firstName} ${userProfile.lastName}";
                                final String pseudo = userProfile.pseudo;
                                Logger.Green.log(userProfile);
                                return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          userProfile.photoURL != ''
                                            ?
                                            ProfilePicture(
                                              name: _getValidName(displayName),
                                              radius: 30,
                                              fontsize: 30,
                                              img: userProfile.photoURL,
                                            )
                                            :
                                            Avatar(
                                              radius: 30,
                                              name: _getValidName(pseudo),
                                              fontsize: 30,
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(pseudo,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold)),
                                                  Text(displayName,
                                                      style: TextStyle(fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Center(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: selectedLang,
                                              icon: Icon(Icons.keyboard_arrow_down),
                                              items: {
                                                'fr': 'Français', // TODO: Localize these names
                                                'en': 'English',
                                                'de': 'Deutsch',
                                                'es': 'Español',
                                              }.entries.map((entry) {
                                                return DropdownMenuItem(
                                                  value: entry.key,
                                                  child: Text(entry.value),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                if (value != null) {
                                                  //context.read<LocalizationCubit>().changeLocale(Locale(value));
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      )
                                  ],
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
          ),



          // === PÉRIODE D'ESSAI (ANIMÉE) ===
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserFreeTrialPeriodAndNotSubscribed) {
                //final int daysUsed = state.daysUsed;
                //final int totalTrial = state.totalTrialDays;
                final int daysUsed = 10;
                final int totalTrial = 30;

                final int daysRemaining =(totalTrial - daysUsed).clamp(0, totalTrial);
                final double progress = daysUsed / totalTrial;

                return TrialPeriodTile(
                  progress: progress,
                  daysRemaining: daysRemaining,
                  onTap: () {
                    closeDrawer(context);
                    DialogHelper().showFreeTrialDialog(context: context);
                  },
                );
              }
              return SizedBox.shrink();
            },
          ),

          // ===== MENU ITEMS =====
         /* VocZillaTile(
            icon: Icons.show_chart,
            label: 'Mes statistiques',
            color: Colors.orange,
            onTap: () => closeDrawer(context),
          ),*/
          VocZillaTile(
            icon: Icons.person,
            label: 'Mon profil',
            color: Colors.green,
            onTap: () {
              closeDrawer(context);
              Navigator.pushNamed(context, '/updateprofile');
            },
          ),

          VocZillaTile(
            icon: Icons.subscriptions_rounded,
            label: context.loc.my_purchase,
            color: Colors.purple,
            onTap: () {
              closeDrawer(context);
              Navigator.pushNamed(context, AppRoute.subscription);
            },
          ),
          VocZillaTile(
            icon: Icons.logout,
            label: 'Déconnexion',
            color: Colors.grey,
            onTap: () {
              closeDrawer(context);
              context.read<AuthBloc>().add(SignOutRequested());
            },
          ),
        ],
      ),
    ),
  );
}

// === CLOSE DRAWER ===

void closeDrawer(BuildContext context) {
  Navigator.of(context).pop();
}
String _getValidName(String? input) {
  final fallback = '?';
  if (input == null || input.trim().isEmpty) return fallback;

  // Remove invalid characters if necessary
  final clean = input.trim().replaceAll(RegExp(r'[^\w\s]'), '');

  return clean.isEmpty ? fallback : clean;
}
