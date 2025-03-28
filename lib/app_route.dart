import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:vobzilla/ui/theme/backgroundBlueLinear.dart';
import 'package:vobzilla/ui/widget/elements/Loading.dart';
import 'core/utils/logger.dart';
import 'data/repository/data_user_repository.dart';
import 'logic/blocs/user/user_bloc.dart';
import 'logic/blocs/user/user_state.dart';

class AppRoute {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String homeLogged = '/home';
  static const String verifiedEmail = '/verifiedemail';
  static const String updateProfile = '/updateprofile';
  static const String subscription = '/subscription';

  static const String learnVocabulary = '/vocabulary/learn/:id';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Logger.Blue.log("APP ROUTE setting name: ${settings.name}");
    bool notRedirectNow = true;
    return MaterialPageRoute(
      settings: settings,
        builder: (context) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, authState) {
              if (authState is AuthAuthenticated) {
                final user = authState.user;
                if (!user!.emailVerified && settings.name != verifiedEmail) {
                  // Redirigez vers l'écran de vérification de l'email
                  user.sendEmailVerification();
                  notRedirectNow = false;
                  _redirectTo(context, settings, verifiedEmail);
                } else
                if ((user.displayName == null || user.displayName!.isEmpty) && settings.name != updateProfile) {
                  // Redirigez vers l'écran de mise à jour du profil
                  notRedirectNow = false;
                  _redirectTo(context, settings, updateProfile);
                } else {
                  final userState = context.read<UserBloc>().state;
                  if (userState is UserFreeTrialPeriodEndAndNotSubscribed) {
                    //redirect subscription
                    notRedirectNow = false;
                    _redirectTo(context, settings, subscription);
                  }else{
                    if(settings.name == login) {
                      notRedirectNow = false;
                      _redirectTo(context, settings, home);
                    }
                  }
                }
              }
            },
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated && notRedirectNow) {
                    return _getAuthenticatedPage(settings);
                }
                if (authState is AuthUnauthenticated && notRedirectNow) {
                  // Logique pour les utilisateurs non authentifiés
                  return _getUnauthenticatedPage(settings);
                }
                return Loading(); // Default loading state
              },
            ),
          );
        }
    );
  }

  static Widget _getUnauthenticatedPage(RouteSettings settings) {
    Logger.Blue.log("_getUnauthenticatedPage settings.name ***********************: ${settings.name}");
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

  static Widget _getAuthenticatedPage(RouteSettings settings) {
    final uri = Uri.parse(settings.name!);
    Logger.Blue.log("_getAuthenticatedPage settings.name ***********************: ${settings.name}");
    if (uri.pathSegments.isNotEmpty) {
      Logger.Blue.log("uri.pathSegments[0] ***********************: ${uri.pathSegments[0]}");
      switch ('/${uri.pathSegments[0]}') {
        case verifiedEmail:
          return Layout(appBarNotLogged: true, logged: false, child: ProfileEmailValidation());
        case updateProfile:
          return Layout(appBarNotLogged: true, logged: false, child: ProfileUpdateScreen());
        case subscription:
          return Layout(child: SubscriptionScreen(), titleScreen: "Nos Abonnements");
        case home:
          return Layout(child: HomeScreen());
        case homeLogged:
          return Layout(child: HomeScreen());
        case '/vocabulary':
          if (uri.pathSegments.length == 3) {
            final id = uri.pathSegments[2];
            switch (uri.pathSegments[1]) {
              case 'learn':
                return Layout(titleScreen: "Apprendre", showBottomNavigationBar: true, itemSelected: 0, id: id, child: LearnScreen(id: id));
              case 'quizz':
                return Layout(titleScreen: "Tester", showBottomNavigationBar: true, itemSelected: 1, id: id, child: QuizzScreen(id: id));
              case 'list':
                return Layout(titleScreen: "Liste", showBottomNavigationBar: true, itemSelected: 2, id: id, child: ListScreen(id: id));
              case 'voicedictation':
                return Layout(titleScreen: "Dictée vocale", showBottomNavigationBar: true, itemSelected: 3, id: id, child: VoiceDictationScreen(id: id));
              case 'statistical':
                return Layout(titleScreen: "Statistique", showBottomNavigationBar: true, itemSelected: 4, id: id, child: StatisticalScreen(id: id));
              default:
                return _errorPage(settings);
            }
          } else {
            return _errorPage(settings);
          }
        default:
          return Layout(child: HomeScreen());
      }
    } else {
      return Layout(child: HomeScreen());
    }
  }
  static void _redirectTo(BuildContext context, RouteSettings settings, String targetRoute) {
    Logger.Blue.log('_redirectTo targetRoute: $targetRoute');
    if (settings.name != targetRoute) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(
          context,
          targetRoute
        );
      });
    }
  }
  static Widget _errorPage(RouteSettings settings, {bool secure = true}) {
    Logger.Red.log('${secure ? "" : "NOT "}SECURE No route defined for ${settings.name}');
    return Scaffold(
      body: Center(
        child: Text('${secure ? "" : "NOT "}SECURE No route defined for ${settings.name}'),
      ),
    );
  }
}
