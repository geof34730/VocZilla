// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:vobzilla/logic/blocs/auth/auth_event.dart';
import 'package:vobzilla/logic/blocs/vocabulaires/vocabulaires_state.dart';
import 'package:vobzilla/ui/theme/theme.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';
import 'app_route.dart';
import 'core/utils/navigatorKey.dart';
import 'core/utils/logger.dart';
import 'data/repository/auth_repository.dart';
import 'data/repository/data_user_repository.dart';
import 'data/repository/vocabulaire_user_repository.dart';
import 'data/services/localstorage_service.dart';
import 'data/services/vocabulaires_server_service.dart';
import 'l10n/app_localizations.dart';
import 'logic/blocs/BlocStateTracker.dart';
import 'logic/blocs/auth/auth_bloc.dart';
import 'logic/blocs/auth/auth_state.dart';
import 'logic/blocs/drawer/drawer_bloc.dart';
import 'logic/blocs/drawer/drawer_state.dart';
import 'logic/blocs/notification/notification_bloc.dart';
import 'logic/blocs/notification/notification_event.dart';
import 'logic/blocs/notification/notification_state.dart';
import 'logic/blocs/purchase/purchase_bloc.dart';
import 'logic/blocs/purchase/purchase_event.dart';
import 'logic/blocs/purchase/purchase_state.dart';
import 'logic/blocs/update/update_event.dart';
import 'logic/blocs/update/update_state.dart';
import 'logic/blocs/user/user_bloc.dart';
import 'logic/blocs/user/user_event.dart';
import 'logic/blocs/user/user_state.dart';
import 'logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import 'logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import 'logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import 'logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import 'logic/blocs/update/update_bloc.dart';




final Route Function(RouteSettings settings) generateRoute = AppRoute.generateRoute;

class MyApp extends StatelessWidget {
  final String? localForce;

  MyApp({super.key, this.localForce});
  //final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final AuthRepository _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: MultiBlocProvider(
        providers: [

          RepositoryProvider(create: (context) => AuthRepository()),
          RepositoryProvider(create: (context) => DataUserRepository()),
          RepositoryProvider(create: (context) => LocalStorageService()),
          RepositoryProvider(create: (context) => VocabulaireServerService()),
          RepositoryProvider(create: (context) => VocabulaireUserRepository()),
          BlocProvider(create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
              dataUserRepository: context.read<DataUserRepository>())
            ..add(AppStarted())),
          BlocProvider(create: (context) => DrawerBloc()),
          BlocProvider(create: (context) => LocalizationCubit()),
          BlocProvider(create: (context) => PurchaseBloc()..add(LoadProducts())),
          BlocProvider(create: (context) => UserBloc()..add(CheckUserStatus())),
          BlocProvider(create: (context) => VocabulairesBloc()),
          BlocProvider(create: (context) => UpdateBloc()..add(CheckForUpdate())),
          BlocProvider(create: (context) => VocabulaireUserBloc()..add(CheckVocabulaireUserStatus())),
          BlocProvider<NotificationBloc>(
            create: (context) => NotificationBloc(),
          ),
        ],
        child: BlocBuilder<LocalizationCubit, Locale>(
          builder: (context, locale) {
            final Locale effectiveLocale = localForce != null
                ? Locale(localForce!)
                : locale;
            FirebaseAuth.instance.setLanguageCode(locale.languageCode);
            return MaterialApp(
              navigatorKey: navigatorKey,
              theme: VobdzillaTheme.lightTheme,
              debugShowCheckedModeBanner: false,
              locale: effectiveLocale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              onGenerateRoute: generateRoute,
              builder: (context, child) {
                return MultiBlocListener(
                  listeners: [
                    BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) =>
                          BlocStateTracker().updateState('AuthBloc', state),
                    ),
                    BlocListener<DrawerBloc, DrawerState>(
                      listener: (context, state) =>
                          BlocStateTracker().updateState('DrawerBloc', state),
                    ),
                    BlocListener<PurchaseBloc, PurchaseState>(
                      listener: (context, state) =>
                          BlocStateTracker().updateState('PurchaseBloc', state),
                    ),
                    BlocListener<UpdateBloc, UpdateState>(
                      listener: (context, state) =>
                          BlocStateTracker().updateState('UpdateBloc', state),
                    ),
                    BlocListener<UserBloc, UserState>(
                      listener: (context, state) =>
                          BlocStateTracker().updateState('UserBloc', state),
                    ),
                    BlocListener<VocabulairesBloc, VocabulairesState>(
                      listener: (context, state) {
                        Logger.Yellow.log("VocabulairesBloc state: $state");
                        BlocStateTracker().updateState('VocabulairesBloc', state);
                      },
                    ),
                    BlocListener<VocabulaireUserBloc, VocabulaireUserState>(
                      listener: (context, state) {
                        Logger.Yellow.log("VocabulaireUserBloc state: $state");
                        BlocStateTracker().updateState(
                            'VocabulaireUserBloc', state);
                      },
                    ),
                    BlocListener<NotificationBloc, NotificationState>(
                      listener: (context, state) {
                        Logger.Yellow.log("NotificationState state: $state");
                        if (state is NotificationVisible) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Future.delayed(const Duration(milliseconds: 50), () {
                              final navigatorContext = navigatorKey.currentContext;
                              if (navigatorContext != null && context.mounted) {
                                ScaffoldMessenger.of(navigatorContext)
                                  ..removeCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(state.message),
                                      backgroundColor: state.backgroundColor,
                                      behavior: SnackBarBehavior.floating,
                                      showCloseIcon: true,
                                      duration: const Duration(seconds: 4),
                                    ),

                                  );
                                context
                                    .read<NotificationBloc>()
                                    .add(NotificationDismissed());
                                context.read<AuthBloc>().add(AuthErrorCleared());
                              }
                            });
                          });
                        }
                      },
                    ),
                  ],
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
