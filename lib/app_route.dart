import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/repository/auth_repository.dart';

import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/logic/blocs/auth/auth_state.dart';
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
        final authState = context
            .watch<AuthBloc>()
            .state;

        if (authState is AuthAuthenticated) {
          final user = authState.user;
          if (!user!.emailVerified) {
            user.sendEmailVerification();
            _redirectTo(context, settings, verifiedEmail);
          } else {
            if (user.displayName == null || user.displayName!.isEmpty) {
              _redirectTo(context, settings, updateProfile);
            }
            else {
              dataUserRepository.synchroDisplayNameWithFirestore(user);
              if (settings.name == login || settings.name == register) {
                _redirectTo(context, settings, home);
                return Loading();
              }
            }
          }

          return _getAuthenticatedPage(settings);
        } else {
          return _getUnauthenticatedPage(settings);
        }
      },
    );
  }

  static void _redirectTo(BuildContext context, RouteSettings settings,
      String targetRoute) {
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

  static Widget _getUnauthenticatedPage(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return HomeLogoutScreen();
      case login:
        return Layout(child: LoginScreen(), logged: false,);
      case register:
        return Layout(child: RegisterScreen(), logged: false,);
      default:
        print('****************NOT SECURE No route defined for ${settings.name}');
        return _errorPage(settings,secure: false);
    }
  }


  static Widget _getAuthenticatedPage(RouteSettings settings) {
    final uri = Uri.parse(settings.name!);
    print("settings.name ***********************: ${settings.name}");
    if (uri.pathSegments.isNotEmpty) {
      switch (uri.pathSegments[0]) {
        case 'verifiedemail':
          return Layout(appBarNotLogged: true, logged: false, child: ProfileEmailValidation());
        case 'updateprofile':
          return Layout(appBarNotLogged: true, logged: false, child: ProfileUpdateScreen());
        case 'subscription': // Assurez-vous que ce cas est correctement défini
          return Layout(child: SubscriptionScreen(),titleScreen: "Nos Abonnements",);
        case 'home':
        case 'homeLogged':
          return Layout(child: HomeScreen());
        case 'vocabulary':
          if (uri.pathSegments.length == 3) {
            final id = uri.pathSegments[2];
            switch (uri.pathSegments[1]) {
              case 'learn':
                return Layout(titleScreen: "Apprendre",showBottomNavigationBar: true, itemSelected: 0, id: id, child: LearnScreen(id: id));
              case 'quizz':
                return Layout(titleScreen: "Tester",showBottomNavigationBar: true, itemSelected: 1, id: id, child: QuizzScreen(id: id));
              case 'list':
                return Layout(titleScreen: "Liste",showBottomNavigationBar: true, itemSelected: 2, id: id, child: ListScreen(id: id));
              case 'voicedictation':
                return Layout(titleScreen: "Dictée vocale",showBottomNavigationBar: true, itemSelected: 3, id: id, child: VoiceDictationScreen(id: id));
              case 'statistical':
                return Layout(titleScreen: "Statistique",showBottomNavigationBar: true, itemSelected: 4, id: id, child: StatisticalScreen(id: id));
              default:
                return _errorPage(settings);
            }
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

  static Widget _errorPage(RouteSettings settings, {bool secure = true}) {
    return Scaffold(
      body: Center(
        child: Text('${secure ? "" : "NOT "}SECURE No route defined for ${settings.name}'),
      ),
    );
  }



}
