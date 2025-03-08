import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/logic/blocs/auth/auth_state.dart';
import 'package:vobzilla/ui/layout.dart';
import 'package:vobzilla/ui/screens/auth/login_screen.dart';
import 'package:vobzilla/ui/screens/auth/profile_email_validation.dart';
import 'package:vobzilla/ui/screens/auth/profile_update_screen.dart';
import 'package:vobzilla/ui/screens/auth/register_screen.dart';
import 'package:vobzilla/ui/screens/home_logout_screen.dart';
import 'package:vobzilla/ui/screens/home_screen.dart';
import 'data/repository/data_user_repository.dart';

class AppRoute {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String homeLogged = '/home';
  static const String verifiedEmail = '/verifiedemail';
  static const String updateProfile = '/updateprofile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context)  {
        final authState = context.watch<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          final user = authState.user;
          if (!user!.emailVerified) {
            user.sendEmailVerification();
            _redirectTo(context, settings, verifiedEmail);
          }else{
            if (user.displayName == null || user.displayName!.isEmpty) {
              _redirectTo(context, settings, updateProfile);
            }
            else{
             dataUserRepository.synchroDisplayNameWithFirestore(user);
             if (settings.name == login || settings.name == register) {
               _redirectTo(context, settings, home);
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

  static void _redirectTo(BuildContext context, RouteSettings settings, String targetRoute) {
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
        return Layout(child: LoginScreen());
      case register:
        return Layout(child: RegisterScreen());
      default:
        return Scaffold(
          body: Center(
            child: Text('NOT SECURE No route defined for ${settings.name}'),
          ),
        );
    }
  }

  static Widget _getAuthenticatedPage(RouteSettings settings) {
    switch (settings.name) {
      case verifiedEmail:
        return Layout(appBarNotLogged: true, child: ProfileEmailValidation());
      case updateProfile:
        return Layout(appBarNotLogged: true, child: ProfileUpdateScreen());

      case home:
      case homeLogged:
        return Layout(child: HomeScreen());
      default:
        return Scaffold(
          body: Center(
            child: Text('SECURE No route defined for ${settings.name}'),
          ),
        );
    }
  }
}
