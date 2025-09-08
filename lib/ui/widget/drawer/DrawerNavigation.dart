import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/logic/cubit/localization_cubit.dart';
import 'package:voczilla/logic/blocs/auth/auth_bloc.dart';
import 'package:voczilla/logic/blocs/user/user_bloc.dart';
import 'package:voczilla/logic/blocs/user/user_state.dart';
import 'package:voczilla/ui/widget/drawer/trial_period_tile.dart';
import 'package:voczilla/ui/widget/drawer/voczilla_tile.dart';
import '../../../app_route.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/string.dart';
import '../../../core/utils/switchLanguageItems.dart';
import '../../../global.dart'; // Needed for daysFreeTrial
import '../../../l10n/app_localizations.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../elements/DialogHelper.dart';

/// The main navigation drawer for the application.
///
/// This has been converted to a `StatelessWidget` to ensure proper `BuildContext`
/// handling and reliable state updates from BLoC, which solves issues where
/// `BlocBuilder` might not update correctly.
class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 5,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // ===== HEADER =====
            _buildDrawerHeader(context),

            // === PÉRIODE D'ESSAI (ANIMÉE) ===

/*
            // ===== TOP MENU ITEMS =====
            _buildMenuItems1(context),

            const Spacer(), // Pousse les widgets suivants vers le bas
            const Divider(),*/
            _buildTrialPeriodTile(),
            _buildMenuItems2(context),

            const _VersionInfoWidget(),
          ],
        ),

      ),

    );
  }
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
                        Row(
                          mainAxisSize: MainAxisSize.min, // largeur minimum
                          children: [
                            Flexible(
                              child: Text(
                                pseudo,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                             padding: EdgeInsets.only(left:5),
                                child:ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(4),
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.pushNamed(context, AppRoute.updateProfile);
                                  },
                                  child: const Icon(
                                    Icons.edit,
                                    size: 22,
                                  ),
                                ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
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

Widget _buildTrialPeriodTile() {
  return BlocBuilder<UserBloc, UserState>( // Ce builder va maintenant recevoir correctement le contexte et les mises à jour
    builder: (context, userState) {
      Logger.Pink.log("********* Drawer userState: $userState");
      if (userState is UserSessionLoaded && userState.isTrialActive && !userState.isSubscribed) {
        Logger.Pink.log("Drawer: Affichage de la tuile de période d'essai.");
        final int daysLeft = userState.trialDaysLeft;
        final double progress = (daysFreeTrial > 0)
            ? (daysFreeTrial - daysLeft).clamp(0, daysFreeTrial) / daysFreeTrial
            : 0.0;
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


Widget _buildMenuItems1(BuildContext context) {
  return Column(
    children: [
      VocZillaTile(
        keyParam: ValueKey('my_personnal_list'),
        icon: Icons.list_alt_outlined,
        label: "Mes listes personnelles",
        color: Colors.blue,
        onTap: () {

        },
      ),
      VocZillaTile(
        keyParam: ValueKey('defined_list'),
        icon: Icons.list_alt_outlined,
        label: "Nos listes prédéfinies",
        color: Colors.green,
        onTap: () {

        },
      ),
      VocZillaTile(
        keyParam: ValueKey('themmes_list'),
        icon: Icons.list_alt_outlined,
        label: "Nos listes des thèmes",
        color: Colors.green,
        onTap: () {

        },
      ),

    ],
  );
}

Widget _buildMenuItems2(BuildContext context) {
  return Column(
    children: [
      VocZillaTile(
        keyParam: ValueKey('link_update_profile'),
        icon: Icons.person,
        label: context.loc.drawer_my_profil,
        color: Colors.purple,
        onTap: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, AppRoute.updateProfile);
        },
      ),
      VocZillaTile(
        keyParam: ValueKey('link_subscription'),
        icon: Icons.subscriptions_rounded,
        label: context.loc.my_purchase,
        color: Colors.purple,
        onTap: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, AppRoute.subscription);
        },
      ),


      if(Platform.isIOS || Platform.isMacOS )
        VocZillaTile(
          keyParam: ValueKey('link_mention1'),
          icon: Icons.info,
          label: context.loc.politique_de_confidentialite,
          color: Colors.purple,
          onTap: () async {
            await openUrl("https://flutter-now.com/voczilla-politique-de-confidentialite/");
          },
        ),
      if(Platform.isIOS || Platform.isMacOS)
        VocZillaTile(
          keyParam: ValueKey('link_mention2'),
          icon: Icons.info,
          label: "${context.loc.conditions_dutilisation} (EULA)",
          color: Colors.purple,
          onTap: () async {
            await openUrl("https://www.apple.com/legal/internet-services/itunes/dev/stdeula/");
          },
        ),


      BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(AppRoute.home, (route) => false);
          }
        },
        child: VocZillaTile(
          keyParam: const ValueKey('link_logout'),
          icon: Icons.logout,
          label: context.loc.drawer_disconnect,
          color: Colors.grey,
          onTap: () {
            Navigator.of(context).pop(); // Ferme le tiroir
            context.read<AuthBloc>().add(SignOutRequested()); // Déclenche l'événement de déconnexion
          },
        ),
      ),
    ],
  );
}

/// Helper function to close the drawer.
void closeDrawer(BuildContext context) {
  Navigator.of(context).pop();
}

Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);
  // Ouvre dans une vue web intégrée (iOS: SFSafariViewController)
  final ok = await launchUrl(
    uri,
    mode: LaunchMode.inAppBrowserView,
    webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
  );
  if (!ok) {
    // fallback : tente l’appli externe (Safari/Chrome)
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Impossible d’ouvrir $url');
    }
  }
}

/// Widget to display the application version from a JSON file.
///
/// This is a StatefulWidget to ensure the version is fetched only once and to
/// handle the asynchronous loading of the version information gracefully.
class _VersionInfoWidget extends StatefulWidget {
  const _VersionInfoWidget();

  @override
  State<_VersionInfoWidget> createState() => _VersionInfoWidgetState();
}

class _VersionInfoWidgetState extends State<_VersionInfoWidget> {
  late final Future<String> _versionFuture;

  @override
  void initState() {
    super.initState();
    _versionFuture = _getVersion();
  }

  Future<String> _getVersion() async {
    try {
      final jsonString = await rootBundle.loadString('deploy-info.json');
      final data = json.decode(jsonString);
      return data['lastVersionName'] as String? ?? 'N/A';
    } catch (e) {
      Logger.Red.log('Failed to load version info: $e');
      return ''; // Return empty on error to hide the widget
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _versionFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Version ${snapshot.data}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

@Deprecated('Use NavigationDrawer widget instead for better state management. Will be removed in a future version.')
Drawer DrawerNavigation({
  required BuildContext context,
}) => const Drawer(child: NavigationDrawer());
