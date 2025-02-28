import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/logic/blocs/auth/auth_state.dart';
import 'package:vobzilla/ui/layout.dart';
import 'package:vobzilla/ui/screens/auth/login_screen.dart';
import 'package:vobzilla/ui/screens/auth/register_screen.dart';
import 'package:vobzilla/ui/screens/home_logout_screen.dart';
import 'package:vobzilla/ui/screens/home_screen.dart';

import 'logic/blocs/auth/auth_event.dart';

class AppRoute {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String homeLogged = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        final authState = context
            .watch<AuthBloc>()
            .state;
        if (authState is AuthAuthenticated) {
          if(settings.name == "/login" || settings.name == "/register"){

            if(settings.name == "/login") {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pop(context, home);
              });
            }
            if(settings.name == "/register") {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                print("POP REGISTER");
                context.read<AuthBloc>().add(SignOutRequested());
                //Navigator.pop(context, login);
              });
            }
            return CircularProgressIndicator();
          }
          else{
            return _getAuthenticatedPage(settings);
          }
        } else {
          print("NOT REDIRECT NOT SECURE");
          return _getUnauthenticatedPage(settings);
        }
      },
    );
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
      case home:
      case homeLogged:
      default:
        return Layout(child: HomeScreen());
    }
  }
}
