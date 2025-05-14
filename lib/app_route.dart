import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/ui/screens/vocabulary/pronunciation_screen.dart';
import 'logic/check_connectivity.dart';
import 'core/utils/logger.dart';
import 'logic/blocs/update/update_state.dart';
import 'logic/blocs/user/user_bloc.dart';
import 'logic/blocs/user/user_state.dart';
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
import 'package:vobzilla/ui/widget/elements/Loading.dart';
import 'logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import 'logic/blocs/vocabulaires/vocabulaires_state.dart';
import 'logic/blocs/update/update_bloc.dart'; // Assurez-vous d'importer UpdateBloc

class AppRoute {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String homeLogged = '/home';
  static const String verifiedEmail = '/verifiedemail';
  static const String updateProfile = '/updateprofile';
  static const String subscription = '/subscription';
  static const String learnVocabulary = '/vocabulary/learn/:id';
  static const String updateScreen = '/update'; // Ajoutez la route pour l'écran de mise à jour

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Logger.Blue.log("APP ROUTE setting name: ${settings.name}");
    bool notRedirectNow = true;
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        UserRepository().checkUserStatusOncePerDay(context);
        return MultiBlocListener(
          listeners: [
            BlocListener<AuthBloc, AuthState>(
              listener: (context, authState) {
                Logger.Red.log('ROUTE listener AuthBloc');
                if (authState is AuthAuthenticated) {
                  final user = authState.user;
                  if (!user!.emailVerified && settings.name != verifiedEmail) {
                    Logger.Red.log('ROUTE !user!.emailVerified');
                    user.sendEmailVerification();
                    notRedirectNow = false;
                    _redirectTo(context, settings, verifiedEmail);
                  } else if ((user.displayName == null || user.displayName!.isEmpty) && settings.name != updateProfile) {
                    Logger.Red.log('ROUTE user.displayName == null');
                    notRedirectNow = false;
                    _redirectTo(context, settings, updateProfile);
                  } else {
                    Logger.Red.log('ROUTE none');
                    if (settings.name == login) {
                      notRedirectNow = false;
                      _redirectTo(context, settings, home);
                    }
                  }
                } else {
                  Logger.Blue.log('ROUTE AuthUnauthenticated');
                  if (settings.name != login && settings.name != register && settings.name != home) {
                    Logger.Blue.log('Redirect logout');
                    notRedirectNow = false;
                    _redirectTo(context, settings, login);
                  }
                }
              },
            ),
            BlocListener<UserBloc, UserState>(
              listener: (context, userState) {
                Logger.Red.log("BlocListener<UserBloc, UserState>");
                if (userState is UserFreeTrialPeriodAndNotSubscribed) {
                  userRepository.showDialogueFreeTrialOnceByDay(context: context);
                }
                if (userState is UserFreeTrialPeriodEndAndNotSubscribed) {
                  Logger.Red.log('ROUTE UserFreeTrialPeriodEndAndNotSubscribed');
                  if (settings.name != subscription) {
                    notRedirectNow = false;
                    Navigator.pushReplacementNamed(context, subscription);
                  }
                }
              },
            ),
            BlocListener<PurchaseBloc, PurchaseState>(
              listener: (context, purchaseState) {
                Logger.Red.log("BlocListener<PurchaseBloc, PurchaseState>");
                if (purchaseState is PurchaseCompleted) {
                  Logger.Red.log('Purchase completed, redirecting to HomeScreen');
                  userRepository.checkUserStatusForce();
                  Navigator.pushReplacementNamed(context, home);
                }
              },
            ),
            BlocListener<UpdateBloc, UpdateState>(
              listener: (context, updateState) {
                if (updateState is UpdateAvailable) {
                  Logger.Red.log('Update available, redirecting to UpdateScreen');
                  Navigator.pushReplacementNamed(context, updateScreen);
                }
              },
            ),
          ],
          child: ConnectivityAwareWidget(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated && notRedirectNow) {
                  return _getAuthenticatedPage(settings, context);
                }
                if (authState is AuthUnauthenticated && notRedirectNow) {
                  return _getUnauthenticatedPage(settings, context);
                }
                return Loading(); // Default loading state
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
      case login:
        return Layout(child: LoginScreen(), logged: false);
      case register:
        return Layout(child: RegisterScreen(), logged: false);
      default:
        return _errorPage(settings, secure: false);
    }
  }

  static Widget _getAuthenticatedPage(RouteSettings settings, BuildContext context) {
    final uri = Uri.parse(settings.name!);
    Logger.Blue.log("_getAuthenticatedPage settings.name: ${settings.name}");

    final userState = context.read<UserBloc>().state;
    if (userState is UserFreeTrialPeriodEndAndNotSubscribed) {
      Logger.Red.log('ROUTE UserFreeTrialPeriodEndAndNotSubscribed');
      return Layout(child: SubscriptionScreen(), titleScreen: "Nos Abonnements");
    }

    if (uri.pathSegments.isNotEmpty) {
      Logger.Blue.log("uri.pathSegments[0]: ${uri.pathSegments[0]}");
      switch ('/${uri.pathSegments[0]}') {
        case verifiedEmail:
          return Layout(appBarNotLogged: true, logged: false, child: ProfileEmailValidation());
        case updateProfile:
          return Layout(
              appBarNotLogged: true,
              logged: false,
              child: ProfileUpdateScreen()
          );
        case subscription:
          return Layout(
              child: SubscriptionScreen(),
              titleScreen: "Nos Abonnements"
          );
        case home:
        case homeLogged:
          return Layout(
              child: HomeScreen()
          );
        case '/vocabulary':
          if (uri.pathSegments.length == 2) {
            return BlocBuilder<VocabulairesBloc, VocabulairesState>(
              builder: (context, vocabulairesState) {
                if (vocabulairesState is VocabulairesLoaded) {
                  String title = "Titre par défaut"; // Titre de secours

                  // Supposons que vocabulairesState.data soit une Map et contienne une clé 'title'
                  if (vocabulairesState.data['titleList'] != null) {
                    final titleData = vocabulairesState.data['titleList'];
                    title = titleData.toString();
                  }
                  switch (uri.pathSegments[1]) {
                    case 'list':
                      return Layout(
                        titleScreen: "$title : ${context.loc.liste_title}",
                        showBottomNavigationBar: true,
                        itemSelected: 0,
                        child: ListScreen(),
                      );
                    case 'learn':
                      return Layout(
                        titleScreen: "$title : ${context.loc.apprendre_title}",
                        showBottomNavigationBar: true,
                        itemSelected: 1,
                        child: LearnScreen(),
                      );
                    case 'voicedictation':
                      return Layout(
                        titleScreen: "$title : ${context.loc.dictation_title}",
                        showBottomNavigationBar: true,
                        itemSelected: 2,
                        child: VoiceDictationScreen(),
                      );
                    case 'pronunciation':
                      return Layout(
                        titleScreen: "$title : ${context.loc.pronunciation_title}",
                        showBottomNavigationBar: true,
                        itemSelected: 3,
                        child: PronunciationScreen(),
                      );
                    case 'quizz':
                      return Layout(
                        titleScreen: "$title : ${context.loc.tester_title}",
                        showBottomNavigationBar: true,
                        itemSelected: 4,
                        child: QuizzScreen(),
                      );
                    case 'statistical':
                      return Layout(
                        titleScreen: "$title : ${context.loc.statistiques_title}",
                        showBottomNavigationBar: true,
                        itemSelected: 5,
                        child: StatisticalScreen(),
                      );
                    default:
                      return _errorPage(settings);
                  }
                } else {
                  // Afficher un écran de chargement tant que l'état n'est pas chargé
                  return Loading();
                }
              },
            );
          } else {
            return _errorPage(settings);
          }
        default:
          return _errorPage(settings);
      }
    } else {
      return Layout(child: HomeScreen());
    }
  }

  static void _redirectTo(BuildContext context, RouteSettings settings, String targetRoute) {
    Logger.Blue.log('_redirectTo targetRoute: $targetRoute ${settings.name}');
    if (settings.name != targetRoute) {
      Logger.Blue.log('REDIRECT GO TO $targetRoute');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context, targetRoute);
      });
    }
  }

  static Widget _errorPage(RouteSettings settings, {bool secure = true}) {
    Logger.Red.log('${secure ? "" : "NOT "}SECURE No route defined for ${settings.name}');
    return Layout(child: Text('${secure ? "" : "NOT "}SECURE No route defined for ${settings.name}'));
  }
}
