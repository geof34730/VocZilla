import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';
import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/logic/blocs/user/user_bloc.dart';
import 'package:vobzilla/logic/blocs/user/user_state.dart';
import 'package:vobzilla/ui/widget/drawer/trial_period_tile.dart';
import 'package:vobzilla/ui/widget/drawer/voczilla_tile.dart';
import '../../../app_route.dart';
import '../../../core/utils/string.dart';
import '../../../core/utils/switchLanguageItems.dart';
import '../../../global.dart'; // Needed for daysFreeTrial
import '../../../l10n/app_localizations.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../elements/DialogHelper.dart';

/// Builds the main navigation drawer for the application.
///
/// Note: For better structure and testability, consider converting this
/// top-level function into a `StatelessWidget` class in the future.
Drawer DrawerNavigation({
  required BuildContext context,
}) {
  return Drawer(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    elevation: 5,
    child: Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ===== HEADER =====
          _buildDrawerHeader(context),

          // === PÉRIODE D'ESSAI (ANIMÉE) ===
          _buildTrialPeriodTile(context),

          // ===== MENU ITEMS =====
          _buildMenuItems(context),
        ],
      ),
    ),
  );
}

/// Builds the header of the drawer, displaying user information.
Widget _buildDrawerHeader(BuildContext context) {
  return DrawerHeader(
    decoration: BoxDecoration(color: Colors.cyan[200]),
    child: BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // If the user is authenticated, display their profile information.
        if (authState is AuthAuthenticated) {
          final userProfile = authState.userProfile;
          final String displayName ="${userProfile.firstName} ${userProfile.lastName}".trim();
          final String pseudo = userProfile.pseudo;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Display the user's avatar or a default one.
                  userProfile.imageAvatar.isNotEmpty
                      ? ClipOval(
                    child: Image.memory(
                      base64Decode(userProfile.imageAvatar),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Avatar(
                          radius: 30,
                          name: GetValidName(pseudo),
                          fontsize: 30,
                        );
                      },
                    ),
                  )
                      : Avatar(
                    radius: 30,
                    name: GetValidName(pseudo),
                    fontsize: 30,
                  ),
                  const SizedBox(width: 12),
                  // Display pseudo and full name.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pseudo,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (displayName.isNotEmpty)
                          Text(
                            displayName,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Language selection dropdown.
              Center(
                child: _buildLanguageDropdown(context),
              ),
            ],
          );
        }
        // Show a loading indicator while the auth state is being determined.
        return const Center(child: CircularProgressIndicator());
      },
    ),
  );
}


Widget _buildLanguageDropdown(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
    child: BlocBuilder<LocalizationCubit, Locale>(
      builder: (context, locale) {
        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: Localizations.localeOf(context).languageCode,
            icon: const Icon(Icons.keyboard_arrow_down),
            items: AppLocalizations.supportedLocales.map((locale) {
              String languageName = switchLanguageItems(languageCode: locale.languageCode);
              return DropdownMenuItem<String>(
                value: locale.languageCode,
                child: Text(languageName),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<LocalizationCubit>().changeLocale(value);
              }
            },
          ),
        );
      },
    ),
  );
}


/// Builds the trial period tile if the user is in their trial period.
Widget _buildTrialPeriodTile(BuildContext context) {
  return BlocBuilder<UserBloc, UserState>(
    builder: (context, userState) {
      if (userState is UserFreeTrialPeriodAndNotSubscribed) {
        final int daysLeft = userState.daysLeft;
        final double progress =(daysFreeTrial - daysLeft).clamp(0, daysFreeTrial) / daysFreeTrial;
        return TrialPeriodTile(
          progress: progress,
          daysRemaining: daysLeft,
          onTap: () {
            Navigator.of(context).pop(); // Close the drawer first.
            DialogHelper()
                .showFreeTrialDialog(context: context, daysLeft: daysLeft);
          },
        );
      }
      // If not in trial, show nothing.
      return const SizedBox.shrink();
    },
  );
}


Widget _buildMenuItems(BuildContext context) {
  return Column(
    children: [
      VocZillaTile(
        icon: Icons.person,
        label: context.loc.drawer_my_profil,
        color: Colors.green,
        onTap: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, AppRoute.updateProfile);
        },
      ),
      VocZillaTile(
        icon: Icons.subscriptions_rounded,
        label: context.loc.my_purchase,
        color: Colors.purple,
        onTap: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, AppRoute.subscription);
        },
      ),
      VocZillaTile(
        icon: Icons.logout,
        label: context.loc.drawer_disconnect,
        color: Colors.grey,
        onTap: () {
          Navigator.of(context).pop();
          context.read<AuthBloc>().add(SignOutRequested());
        },
      ),
    ],
  );
}

/// Helper function to close the drawer.
void closeDrawer(BuildContext context) {
  Navigator.of(context).pop();
}

/// Helper function to provide a valid name for the Avatar widget.

