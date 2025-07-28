// lib/app_route.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/ui/featureGraphic.dart';
import 'package:vobzilla/ui/screens/auth/profile_update_screen_gafa.dart';
import 'package:vobzilla/ui/screens/personalisation/step2.dart';
import 'package:vobzilla/ui/screens/update_screen.dart';

import 'core/utils/errorMessage.dart';
import 'core/utils/feature_graphic_flag.dart';
import 'data/models/user_firestore.dart';
import 'logic/blocs/auth/auth_event.dart';
import 'logic/blocs/notification/notification_bloc.dart';
import 'logic/blocs/notification/notification_event.dart';
import 'logic/blocs/user/user_event.dart';
import 'logic/check_connectivity.dart';
import 'core/utils/logger.dart';
import 'logic/blocs/update/update_state.dart';
import 'logic/blocs/user/user_bloc.dart';
import 'logic/blocs/user/user_state.dart';
import 'package:vobzilla/ui/screens/vocabulary/pronunciation_screen.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/data/repository/user_repository.dart';
import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/logic/blocs/auth/auth_state.dart';
import 'package:vobzilla/logic/blocs/purchase/purchase_bloc.dart';
import 'package:vobzilla/logic/blocs/purchase/purchase_state.dart';
import 'package:vobzilla/ui/layout.dart';
import 'package:vobzilla/ui/screens/auth/login_screen.dart';
import 'package:vobzilla/ui/screens/auth/profile_email_validation.dart';
import 'package:vobzilla/ui/screens/auth/profile_update_screen.dart';
import 'package:vobzilla/ui/screens/auth/register_screen.dart';
import 'package:vobzilla/ui/screens/home_logout_screen.dart';
import 'package:vobzilla/ui/screens/home_screen.dart';
import 'package:vobzilla/ui/screens/subscription_screen.dart';
import 'package:vobzilla/ui/screens/vocabulary/learn_screen.dart';
import 'package:vobzilla/ui/screens/vocabulary/list_screen.dart';
import 'package:vobzilla/ui/screens/vocabulary/quizz_screen.dart';
import 'package:vobzilla/ui/screens/vocabulary/statistical.screen.dart';
import 'package:vobzilla/ui/screens/vocabulary/voice_dictation_screen.dart';
import 'package:vobzilla/ui/screens/personalisation/step1.dart';
import 'package:vobzilla/ui/widget/elements/Loading.dart';
import 'logic/blocs/update/update_bloc.dart';

class AppRoute {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String homeLogged = '/home';
  static const String verifiedEmail = '/verifiedemail';
  static const String updateProfile = '/updateprofile';
  static const String updateProfileGafa = '/updateprofilegafa';
  static const String subscription = '/subscription';
  static const String updateScreen = '/update';
  static const String featureGraphic = '/featureGraphic';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Logger.Blue.log("APP ROUTE setting name: ${settings.name}");
   if (forFeatureGraphic && settings.name == AppRoute.home) {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => FeatureGraphic(),
      );
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        UserRepository().checkUserStatusOncePerDay(context);
        return MultiBlocListener(
          listeners: [
            BlocListener<AuthBloc, AuthState>(
              listener: (context, authState) {
                if (authState is AuthAuthenticated && authState is! AuthProfileUpdated) {
                  final userProfile = authState.userProfile;
                  final firebaseUser = FirebaseAuth.instance.currentUser;
                  if (firebaseUser == null) {
                   //_redirectTo(context, settings, login);
                    return;
                  }
                  if (userProfile.isProfileIncomplete && settings.name != updateProfileGafa) {
                    _redirectTo(context, settings, updateProfileGafa);
                  } else if (!firebaseUser.emailVerified &&
                      settings.name != verifiedEmail &&
                      !firebaseUser.providerData.any((info) =>
                      info.providerId == 'facebook.com' ||
                          info.providerId == 'google.com' ||
                          info.providerId == 'apple.com')) {
                    try {
                      firebaseUser.sendEmailVerification();
                    } catch (e) {
                      if (context.mounted && e is FirebaseAuthException ) {
                        context.read<NotificationBloc>().add(ShowNotification(
                          message: getLocalizedErrorMessage(context, e.code),
                          backgroundColor: Colors.orange,
                        ));
                      }
                    }
                    _redirectTo(context, settings, verifiedEmail);
                  } else if (settings.name == login) {
                    _redirectTo(context, settings, home);
                  }
                } else if (authState is AuthUnauthenticated) {
                  if (settings.name != login && settings.name != register && settings.name != home) {
                    _redirectTo(context, settings, login);
                  }
                }
                if (authState is AuthError) {
                  context.read<NotificationBloc>().add(ShowNotification(
                    message: getLocalizedErrorMessage(context, authState.message),
                    backgroundColor: Colors.red,
                  ));
                  context.read<AuthBloc>().add(AuthErrorCleared());
                }
                if (authState is AuthSuccess) {
                  // Cette partie est correcte et continue de fonctionner pour la notification
                  context.read<NotificationBloc>().add(ShowNotification(
                    message: getLocalizedSuccessMessage(context, authState.message),
                    backgroundColor: Colors.green,
                  ));
                }
              },
            ),
            BlocListener<UpdateBloc, UpdateState>(
              listener: (context, updateState) {
                if (updateState is UpdateAvailable) {
                  Navigator.pushReplacementNamed(context, updateScreen);
                }
              },
            ),
            BlocListener<PurchaseBloc, PurchaseState>(
              listener: (context, purchaseState) {
                if (purchaseState is PurchaseCompleted) {
                  userRepository.checkUserStatusForce();
                  Navigator.pushReplacementNamed(context, home);
                }
              },
            ),
          ],
          child: ConnectivityAwareWidget(
            child: BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (previous, current) {
                return current is! AuthSuccess && current is! AuthProfileUpdated;
              },
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  return _getAuthenticatedPage(settings, context);
                }
                if (authState is AuthUnauthenticated || authState is AuthError) {
                  return _getUnauthenticatedPage(settings, context);
                }
                return Scaffold(
                  body: Loading(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  static Widget _getUnauthenticatedPage(RouteSettings settings, BuildContext context) {
    Logger.Blue.log("_getUnauthenticatedPage settings.name: ${settings.name}");
    switch (settings.name) {
      case home:
        return HomeLogoutScreen();
      case featureGraphic:
        return FeatureGraphic();
      case login:
      // MODIFICATION : On extrait les arguments et on les passe à LoginScreen.
        final args = settings.arguments as Map<String, dynamic>?;
        return Layout(
          logged: false,
          child: LoginScreen(),
        );
      case register:
        return Layout(logged: false, child: RegisterScreen());
      case updateScreen:
        return Layout(titleScreen: context.loc.title_app_update, child: UpdateScreen());
      default:
        return _errorPage(settings, secure: false);
    }
  }

  static Widget _getAuthenticatedPage(RouteSettings settings, BuildContext context) {
    // ... (contenu de la fonction inchangé)
    final uri = Uri.parse(settings.name ?? '');
    Logger.Blue.log("_getAuthenticatedPage settings.name: ${settings.name}");

    if (uri.pathSegments.isEmpty && settings.name == '/') {
      return Layout(child: HomeScreen());
    }

    if (uri.pathSegments.isNotEmpty) {
      final rootPath = '/${uri.pathSegments[0]}';
      switch (rootPath) {
        case verifiedEmail:
          return Layout(appBarNotLogged: true, logged: false, child: ProfileEmailValidation());
        case updateProfile:
          return Layout(appBarNotLogged: false, logged: true, child: ProfileUpdateScreen());
        case login:
          return Scaffold(body: Loading());
        case updateProfileGafa:
          return Layout(appBarNotLogged: true, logged: false, child: ProfileUpdateGafaScreen());
        case subscription:
          return Layout(titleScreen: context.loc.title_subscription, child: SubscriptionScreen());
        case home:
        case homeLogged:
          return Layout(child: HomeScreen());
        case updateScreen:
          return Layout(titleScreen: context.loc.title_app_update, child: UpdateScreen());
        case '/vocabulary':
          if (uri.pathSegments.length == 2) {
            switch (uri.pathSegments[1]) {
              case 'list':
                return Layout(
                  titleScreen: context.loc.liste_title,
                  showBottomNavigationBar: true,
                  itemSelected: 0,
                  child: ListScreen(),
                );
              case 'learn':
                return Layout(
                  titleScreen: context.loc.apprendre_title,
                  showBottomNavigationBar: true,
                  itemSelected: 1,
                  child: LearnScreen(),
                );
              case 'voicedictation':
                return Layout(
                  titleScreen: context.loc.dictation_title,
                  showBottomNavigationBar: true,
                  itemSelected: 2,
                  child: VoiceDictationScreen(),
                );
              case 'pronunciation':
                return Layout(
                  titleScreen: context.loc.pronunciation_title,
                  showBottomNavigationBar: true,
                  itemSelected: 3,
                  child: PronunciationScreen(),
                );
              case 'quizz':
                return Layout(
                  titleScreen: context.loc.tester_title,
                  showBottomNavigationBar: true,
                  itemSelected: 4,
                  child: QuizzScreen(),
                );
              case 'statistical':
                return Layout(
                  titleScreen: context.loc.statistiques_title,
                  showBottomNavigationBar: true,
                  itemSelected: 5,
                  child: StatisticalScreen(),
                );
              default: return _errorPage(settings);
            }
          }
          return _errorPage(settings);

        case '/personnalisation':
          if (uri.pathSegments.length > 1) {
            switch (uri.pathSegments[1]) {
              case 'step1':
                return Layout(
                  titleScreen: context.loc.title_create_personal_list,
                  child: PersonnalisationStep1Screen(
                    guidListPerso: uri.pathSegments.length == 3 ? uri.pathSegments[2] : null,
                  ),
                );
              case 'step2':
                return Layout(
                  titleScreen: context.loc.title_create_personal_list,
                  child: PersonnalisationStep2Screen(
                    guidListPerso: uri.pathSegments[2],
                  ),
                );
              default:
                return _errorPage(settings);
            }
          }
          return _errorPage(settings);
        default:
          return _errorPage(settings);
      }
    }
    return Layout(child: HomeScreen());
  }


  static void _redirectTo(BuildContext context, RouteSettings settings, String targetRoute, {Object? arguments}) {
    if (settings.name != targetRoute) {
      Logger.Blue.log('REDIRECTING TO $targetRoute from ${settings.name}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            targetRoute,
                (Route<dynamic> route) => false,
            arguments: arguments, // On passe les arguments à la navigation
          );
        }
      });
    }
  }

  static Widget _errorPage(RouteSettings settings, {bool secure = true}) {
    return Layout(child: Center(child: Text('Page non trouvée pour la route : ${settings.name}')));
  }
}
