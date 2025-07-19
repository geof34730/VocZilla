import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/ui/featureGraphic.dart';
import 'package:vobzilla/ui/screens/personalisation/step2.dart';
import 'package:vobzilla/ui/screens/update_screen.dart';

import 'core/utils/feature_graphic_flag.dart';
import 'logic/blocs/auth/auth_event.dart';
import 'logic/blocs/notification/notification_bloc.dart';
import 'logic/blocs/notification/notification_event.dart';
import 'logic/blocs/notification/notification_state.dart';
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
  static const String updateScreen = '/update';
  static const String featureGraphic = '/featureGraphic';

  // Ajoutez la route pour l'écran de mise à jour

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Logger.Blue.log("APP ROUTE setting name: ${settings.name}");
    if (forFeatureGraphic && settings.name == AppRoute.home) {
      // Redirige vers la page FeatureGraphic
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => FeatureGraphic(),
      );
    }



    bool notRedirectNow = true;
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        UserRepository().checkUserStatusOncePerDay(context);
        return MultiBlocListener(
          listeners: [
            BlocListener<AuthBloc, AuthState>(
              listener: (context, authState) async {
                Logger.Red.log('ROUTE listener AuthBloc');
                if (authState is AuthAuthenticated) {
                  final user = authState.user;

                  // 1. Ajout d'une vérification de nullité pour la robustesse
                  if (user == null) {
                   // _redirectTo(context, settings, login);
                    return;
                  }
                  if (!user.emailVerified &&
                      settings.name != verifiedEmail &&
                      !user.providerData.any((info) =>
                      info.providerId == 'facebook.com' ||
                          info.providerId == 'google.com' ||
                          info.providerId == 'apple.com'
                      )
                  ){
                    Logger.Red.log('ROUTE !user!.emailVerified');
                    try {
                      await user.sendEmailVerification();
                    } catch (e) {
                      if (context.mounted && e is FirebaseAuthException && e.code == 'too-many-requests') {
                          // Affiche un message à l'utilisateur
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Trop de demandes. Réessaie plus tard."))
                          );
                      }
                    }
                    notRedirectNow = false;
                    Logger.Green.log("REDIRIGE VERS VERIFER EMAIL PAS EMAIL VALIDE");
                    Navigator.pushReplacementNamed(context, verifiedEmail);
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
                if (FirebaseAuth.instance.currentUser != null) {
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
                }
              },
            ),
            BlocListener<PurchaseBloc, PurchaseState>(
              listener: (context, purchaseState) {
                if (FirebaseAuth.instance.currentUser != null) {
                  Logger.Red.log("BlocListener<PurchaseBloc, PurchaseState>");
                  if (purchaseState is PurchaseCompleted) {
                    Logger.Red.log('Purchase completed, redirecting to HomeScreen');
                    userRepository.checkUserStatusForce();
                    Navigator.pushReplacementNamed(context, home);
                  }
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
      case featureGraphic:
        return FeatureGraphic();
      case login:
        return Layout(logged: false, child: LoginScreen());
      case register:
        return Layout(logged: false, child: RegisterScreen());
      default:
        return _errorPage(settings, secure: false);
    }
  }

  static Widget _getAuthenticatedPage(RouteSettings settings, BuildContext context) {
    final uri = Uri.parse(settings.name ?? ''); // 2. Sécurisation contre un `settings.name` nul
    Logger.Blue.log("_getAuthenticatedPage settings.name: ${settings.name}");

    final userState = context.read<UserBloc>().state;
    if (userState is UserFreeTrialPeriodEndAndNotSubscribed) {
      Logger.Red.log('ROUTE UserFreeTrialPeriodEndAndNotSubscribed');
      if (FirebaseAuth.instance.currentUser != null) {
        return Layout(titleScreen: context.loc.title_subscription, child: SubscriptionScreen());
      }
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
        case register:
          return Layout(logged: false, child: RegisterScreen());
        case subscription:
          return Layout(
              titleScreen: context.loc.title_subscription,
              child: SubscriptionScreen()
          );
        case home:
        case homeLogged:
          return Layout(
              child: HomeScreen()
          );

        case updateScreen:
          return Layout(
              titleScreen: context.loc.title_app_update,
              child: UpdateScreen()
          );
        case '/vocabulary':
          if (uri.pathSegments.length == 2) {
            return BlocBuilder<VocabulairesBloc, VocabulairesState>(
              builder: (context, vocabulairesState) {
                if (vocabulairesState is VocabulairesLoaded) {
                  String title = "Default title"; // Titre de secours
                  if (vocabulairesState.data.titleList.isNotEmpty) {
                    title = vocabulairesState.data.titleList;
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
        case '/personnalisation':
          if (uri.pathSegments.length > 1) {
                  switch (uri.pathSegments[1]) {
                    case 'step1':
                      return Layout(
                        titleScreen: context.loc.title_create_personal_list,
                        showBottomNavigationBar: false,
                        child:  uri.pathSegments.length==3 ?
                          PersonnalisationStep1Screen(
                            guidListPerso: uri.pathSegments[2],
                          )
                          :
                          PersonnalisationStep1Screen()
                        ,
                      );
                    case 'step2':
                      return Layout(
                        titleScreen: context.loc.title_create_personal_list,
                        showBottomNavigationBar: false,
                        child:  PersonnalisationStep2Screen(
                          guidListPerso: uri.pathSegments[2],
                        ),
                      );
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

  static void _redirectTo(BuildContext context, RouteSettings settings, String targetRoute) {
    Logger.Blue.log('_redirectTo targetRoute: $targetRoute from ${settings.name}');
    if(settings.name==verifiedEmail && targetRoute==login){
      //context.read<AuthBloc>().add(SignOutRequested());
    //  Navigator.pushNamedAndRemoveUntil(context, targetRoute, (Route<dynamic> route) => false);
    }


    if (settings.name != targetRoute) {
      Logger.Blue.log('REDIRECTING TO $targetRoute');
      // 3. Correction de la logique de redirection
      // L'utilisation précédente de `Navigator.pop` était incorrecte et provoquait des crashs.
      // On utilise `pushNamedAndRemoveUntil` pour naviguer vers la nouvelle route et supprimer
      // tout l'historique, ce qui est le comportement attendu pour un changement d'état d'authentification.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, targetRoute, (Route<dynamic> route) => false);
      });
    }
  }

  static Widget _errorPage(RouteSettings settings, {bool secure = true}) {
    Logger.Red.log('${secure ? "" : "NOT "}SECURE No route defined for ${settings.name}');
    return Layout(child: Text('${secure ? "" : "NOT "}SECURE No route defined for ${settings.name}'));
  }
}
