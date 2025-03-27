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
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        final authState = context.watch<AuthBloc>().state;

        if (authState is AuthAuthenticated) {
          final user = authState.user;
          if (!user!.emailVerified && settings.name != verifiedEmail) {
            // Redirigez vers l'écran de vérification de l'email
            user.sendEmailVerification();
            _redirectTo(context, settings, verifiedEmail);
            return Loading();
          } else if ((user.displayName == null || user.displayName!.isEmpty) && settings.name != updateProfile) {
            // Redirigez vers l'écran de mise à jour du profil
            _redirectTo(context, settings, updateProfile);
            return Loading();
          } else {
            final userState = context.watch<UserBloc>().state;
            if(userState is UserFreeTrialPeriodEndAndNotSubscribed) {
              //redirect subscription
              _redirectTo(context, settings, subscription);
            }
          }
          return _getAuthenticatedPage(settings);
        } else {
          // Logique pour les utilisateurs non authentifiés
          return _getUnauthenticatedPage(settings);
        }
      },
    );
  }

  static Widget _getUnauthenticatedPage(RouteSettings settings) {
    print("_getUnauthenticatedPage settings.name ***********************: ${settings.name}");
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
    print("_getAuthenticatedPage settings.name ***********************: ${settings.name}");
    if (uri.pathSegments.isNotEmpty) {
      print("uri.pathSegments[0] ***********************: ${uri.pathSegments[0]}");
      switch ('/${uri.pathSegments[0]}') {
        case verifiedEmail:
          print("ok verified email");
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
    print('targetRoute $targetRoute');
    if (settings.name != targetRoute) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          targetRoute,
          (Route<dynamic> route) => false,
        );
      });
    }
  }
  static Widget _errorPage(RouteSettings settings, {bool secure = true}) {
    return Scaffold(
      body: Center(
        child: Text('${secure ? "" : "NOT "}SECURE No route defined for ${settings.name}'),
      ),
    );
  }
}
