// lib/app_route.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/ui/featureGraphic.dart';
import 'package:voczilla/ui/screens/auth/profile_update_screen.dart';
import 'package:voczilla/ui/screens/personalisation/step2.dart';
import 'package:voczilla/ui/screens/share_screen.dart';
import 'package:voczilla/ui/screens/update_screen.dart';
import 'package:voczilla/ui/screens/vocabulary/all_lists_defined.dart';
import 'package:voczilla/ui/screens/vocabulary/all_lists_perso.dart';
import 'package:voczilla/ui/screens/vocabulary/all_lists_themes.dart';

import 'data/repository/vocabulaire_user_repository.dart';
import 'global.dart';
import 'logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import 'logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import 'logic/check_connectivity.dart';
import 'core/utils/logger.dart';
import 'logic/blocs/update/update_state.dart';
import 'logic/blocs/user/user_bloc.dart';
import 'logic/blocs/user/user_state.dart';
import 'package:voczilla/ui/screens/vocabulary/pronunciation_screen.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/data/repository/user_repository.dart';
import 'package:voczilla/logic/blocs/auth/auth_bloc.dart';
import 'package:voczilla/logic/blocs/auth/auth_state.dart';
import 'package:voczilla/logic/blocs/purchase/purchase_bloc.dart';
import 'package:voczilla/logic/blocs/purchase/purchase_state.dart';
import 'package:voczilla/ui/layout.dart';
import 'package:voczilla/ui/screens/home_logout_screen.dart';
import 'package:voczilla/ui/screens/home_screen.dart';
import 'package:voczilla/ui/screens/subscription_screen.dart';
import 'package:voczilla/ui/screens/vocabulary/learn_screen.dart';
import 'package:voczilla/ui/screens/vocabulary/list_screen.dart';
import 'package:voczilla/ui/screens/vocabulary/quizz_screen.dart';
import 'package:voczilla/ui/screens/vocabulary/statistical.screen.dart';
import 'package:voczilla/ui/screens/vocabulary/voice_dictation_screen.dart';
import 'package:voczilla/ui/screens/personalisation/step1.dart';
import 'package:voczilla/ui/widget/elements/Loading.dart';
import 'logic/blocs/update/update_bloc.dart';

class AppRoute {
  static const String home = '/';
  static const String homeLogged = '/home';
  static const String login = '/login';
  static const String updateProfile = '/updateprofile';
  static const String subscription = '/subscription';
  static const String updateScreen = '/update';
  static const String featureGraphic = '/featureGraphic';
  static const String allListsDefined = '/alllistsdefined';
  static const String allListsPerso = '/alllistsperso';
  static const String allListsThemes = '/allliststhemes';
  static const String share = '/share';



  static Route<dynamic> generateRoute(RouteSettings settings) {
    Logger.Blue.log("APP ROUTE setting name: ${settings.name}");
    print("*************************** ${settings.name} **************************");
   if (forFeatureGraphic) {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => FeatureGraphic(),
      );
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        return MultiBlocListener(
          listeners: [
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (previous, current) {
                // Ne réagit qu'à la transition de déconnecté à connecté.
                return previous is! AuthAuthenticated && current is AuthAuthenticated;
              },
              listener: (context, authState) {
                if (authState is AuthAuthenticated && authState is! AuthProfileUpdated) {
                  // On vérifie le statut de l'utilisateur UNE SEULE FOIS, ici.
                  UserRepository().checkUserStatusOncePerDay(context);
                  //final userProfile = authState.userProfile;
                  final firebaseUser = FirebaseAuth.instance.currentUser;
                  if (firebaseUser == null) {
                    //_redirectTo(context, settings, login);
                    return;
                  }
                }
              },
            ),
            BlocListener<UserBloc, UserState>(
              listener: (context, userState) {
                final userBlocInstance = context.read<UserBloc>();
                if (settings.name != subscription) {
                  if (userState is UserSessionLoaded) {
                    // User is in trial and not subscribed, show the dialog
                    if (userState.isTrialActive && !userState.isSubscribed) {
                      if(!testScreenShot) {
                        userRepository.showDialogueFreeTrialOnceByDay(context: context);
                      }
                    }
                    // User's trial has ended and they are not subscribed, force to subscription page
                    else if (!userState.isTrialActive && !userState.isSubscribed) {
                      Logger.Red.log('ROUTE: Trial ended and not subscribed. Redirecting to subscription page.');
                      Navigator.pushReplacementNamed(
                          context,
                          subscription,
                          arguments: {'endTrial': true}
                      );
                    }
                  }
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

    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    analytics.logEvent(
      name: 'screen',
      parameters: {'screen': settings.name ?? ''},
    );

    final uri = Uri.parse(settings.name ?? '');
    final rootPath = uri.pathSegments.isNotEmpty ? '/${uri.pathSegments[0]}' : '/';
    switch (rootPath) {

      case home:
        return HomeLogoutScreen();
      case featureGraphic:
        return FeatureGraphic();
      case updateScreen:
        return Layout(titleScreen: context.loc.title_app_update, child: UpdateScreen());
      case '/share':
        if (uri.pathSegments.length == 2) {
          return (Layout(titleScreen: "param 2",child: ShareScreen(guidlist: uri.pathSegments[1])));
        }
        return _errorPage(settings, secure: false);
     default:
        return _errorPage(settings, secure: false);
    }
  }

  static Widget _getAuthenticatedPage(RouteSettings settings, BuildContext context) {
    final uri = Uri.parse(settings.name ?? '');
    Logger.Blue.log("_getAuthenticatedPage settings.name: ${settings.name}");

    if (uri.pathSegments.isNotEmpty) {
      final rootPath = '/${uri.pathSegments[0]}';
      switch (rootPath) {
        case updateProfile:
          return Layout(appBarNotLogged: false, logged: true, child: ProfileUpdateScreen());
        case subscription:
          return Layout(titleScreen: context.loc.title_subscription, child: SubscriptionScreen());
        case home:
        case homeLogged:
          return Layout(child: HomeScreen());
        case '/share':
          if (uri.pathSegments.length == 2) {
            return (Layout(titleScreen: "param 2",child: ShareScreen(guidlist: uri.pathSegments[1])));
          }
          return _errorPage(settings, secure: false);

        case allListsDefined:
          return Layout(
              child: AllListsDefinedScreen(),
          //    titleScreen: context.loc.title_all_list_defined

          );
        case allListsPerso:
          return Layout(actionButtonAddListPerso:true, child: AllListsPersoScreen());
        case allListsThemes:
          return Layout(child: AllListsThemesScreen());
        case updateScreen:
          return Layout(titleScreen: context.loc.title_app_update, child: UpdateScreen());
        case '/vocabulary':
          if (uri.pathSegments.length == 3) {
            switch (uri.pathSegments[1]) {
              case 'list':
                return Layout(
                  titleScreen: context.loc.liste_title,
                  showBottomNavigationBar: true,
                  itemSelected: 0,
                  listName: uri.pathSegments[2],
                  child: ListScreen(listName: uri.pathSegments[2]),
                );
              case 'learn':
                return Layout(
                  titleScreen: context.loc.apprendre_title,
                  showBottomNavigationBar: true,
                  itemSelected: 1,
                  listName: uri.pathSegments[2],
                  child: LearnScreen(listName: uri.pathSegments[2]),
                );
              case 'voicedictation':
                return Layout(
                  titleScreen: context.loc.dictation_title,
                  showBottomNavigationBar: true,
                  itemSelected: 2,
                  listName: uri.pathSegments[2],
                  child: VoiceDictationScreen(listName: uri.pathSegments[2]),
                );
              case 'pronunciation':
                return Layout(
                  titleScreen: context.loc.pronunciation_title,
                  showBottomNavigationBar: true,
                  itemSelected: 3,
                  listName: uri.pathSegments[2],
                  child: PronunciationScreen(listName: uri.pathSegments[2]),
                );
              case 'quizz':
                return Layout(
               //   titleScreen: context.loc.tester_title,
                  showBottomNavigationBar: true,
                  itemSelected: 4,
                  listName: uri.pathSegments[2],
                  child: QuizzScreen(listName: uri.pathSegments[2]),
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
