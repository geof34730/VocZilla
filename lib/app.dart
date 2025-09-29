// lib/app.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:voczilla/data/repository/user_repository.dart';
import 'package:voczilla/data/services/leaderboard_service.dart';

import 'package:voczilla/logic/blocs/auth/auth_event.dart';
import 'package:voczilla/logic/blocs/vocabulaires/vocabulaires_state.dart';
import 'package:voczilla/services/global_ad_manager.dart';
import 'package:voczilla/ui/theme/theme.dart';
import 'package:voczilla/logic/cubit/localization_cubit.dart';
import 'app_route.dart';
import 'core/utils/errorMessage.dart';
import 'core/utils/languageUtils.dart';
import 'core/utils/navigatorKey.dart';
import 'core/utils/logger.dart';
import 'data/repository/auth_repository.dart';
import 'data/repository/data_user_repository.dart';
import 'data/repository/leaderboard_repository.dart';
import 'data/repository/vocabulaire_user_repository.dart';
import 'data/services/localstorage_service.dart';
import 'data/services/vocabulaires_server_service.dart';
import 'global.dart';
import 'l10n/app_localizations.dart';
import 'logic/blocs/BlocStateTracker.dart';
import 'logic/blocs/auth/auth_bloc.dart';
import 'logic/blocs/auth/auth_state.dart';
import 'logic/blocs/drawer/drawer_bloc.dart';
import 'logic/blocs/drawer/drawer_state.dart';
import 'logic/blocs/leaderboard/leaderboard_bloc.dart';
import 'logic/blocs/leaderboard/leaderboard_event.dart';
import 'logic/blocs/notification/notification_bloc.dart';
import 'logic/blocs/notification/notification_event.dart';
import 'logic/blocs/notification/notification_state.dart';
import 'logic/blocs/purchase/purchase_bloc.dart';
import 'logic/blocs/purchase/purchase_event.dart';
import 'logic/blocs/purchase/purchase_is_subscribed_bloc.dart';
import 'logic/blocs/purchase/purchase_state.dart';
import 'logic/blocs/update/update_event.dart';
import 'logic/blocs/update/update_state.dart';
import 'logic/blocs/user/user_bloc.dart';
import 'logic/blocs/user/user_event.dart';
import 'logic/blocs/user/user_state.dart';
import 'logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import 'logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import 'logic/blocs/vocabulaire_user/vocabulaire_user_state.dart' hide VocabulaireUserUpdate;
import 'logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import 'logic/blocs/update/update_bloc.dart';
import 'logic/blocs/vocabulaires/vocabulaires_event.dart';
import 'main.dart';

final Route Function(RouteSettings settings) generateRoute = AppRoute.generateRoute;

class MyApp extends StatelessWidget {
  final String? localForce;

  MyApp({super.key, this.localForce});

  @override
  Widget build(BuildContext context) {

    VocabulaireUserRepository().getCountVocabulaireAll(local: 'fr').then((value){
      globalCountVocabulaireAll=value;
    });
    return Material(
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (context) => AuthRepository()),
          RepositoryProvider(create: (context) => DataUserRepository()),
          RepositoryProvider(create: (context) => LocalStorageService()),
          RepositoryProvider(create: (context) => VocabulaireServerService()),
          RepositoryProvider(create: (context) => VocabulaireUserRepository()),
          RepositoryProvider(create: (context) => UserRepository()), // Instance unique
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => AuthBloc(
                authRepository: context.read<AuthRepository>(),
                dataUserRepository: context.read<DataUserRepository>())
              ..add(AppStarted())),
            BlocProvider(create: (context) => DrawerBloc()),
            BlocProvider(create: (context) => LocalizationCubit()),
            BlocProvider(create: (context) => PurchaseBloc()..add(LoadProducts())),
            BlocProvider(create: (context) => UserBloc(context.read<UserRepository>())),
            BlocProvider(create: (context) => VocabulairesBloc()),
            BlocProvider(create: (context) => UpdateBloc()..add(CheckForUpdate())),
            BlocProvider(create: (context) => NotificationBloc()),
            BlocProvider<PurchaseIsSubscribedBloc>(
              create: (context) => PurchaseIsSubscribedBloc(
                userRepository: context.read<UserRepository>(),
              )..add(CheckPurchaseSubscriptionStatus()),
            ),
          ],
          child: BlocBuilder<LocalizationCubit, Locale>(
            builder: (context, locale) {
              final Locale effectiveLocale = localForce != null
                  ? Locale(localForce!)
                  : locale;
              FirebaseAuth.instance.setLanguageCode(locale.languageCode);

              return GlobalAdManager(
                child: MaterialApp(
                navigatorObservers: [routeObserver],
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
                  final smallCode = localForce ?? LanguageUtils.getSmallCodeLanguage(context: context);

                  return MultiBlocProvider(
                    providers: [
                      BlocProvider<VocabulaireUserBloc>(
                        create: (context) => VocabulaireUserBloc()
                          ..add(CheckVocabulaireUserStatus(local: smallCode)),
                      ),
                      BlocProvider<LeaderboardBloc>(
                        create: (context) => LeaderboardBloc(
                          leaderboardRepository: LeaderboardRepository(
                            leaderboardService: LeaderboardService(),
                            vocabulaireUserRepository: VocabulaireUserRepository(),
                          ),
                        )..add(FetchLeaderboard(local: smallCode)),
                      ),
                    ],
                      child: BlocConsumer<LocalizationCubit, Locale>(
                        listenWhen: (previous, current) => previous != current,
                        listener: (context, locale) {
                          final localCode = locale.languageCode.toLowerCase();
                          context.read<VocabulairesBloc>().add(LocaleChangedVocabulaires(local: localCode));
                        },
                        builder: (context, locale) {
                          return MultiBlocListener(
                            listeners: [
                              BlocListener<AuthBloc, AuthState>(
                                listener: (context, state) {
                                  if (state is AuthAuthenticated) {
                                    Logger.Green.log(
                                        "User is authenticated, loading user data for UID: ${state
                                            .userProfile.uid}");
                                    context.read<UserBloc>().add(
                                        InitializeUserSession());
                                  } else if (state is AuthUnauthenticated) {
                                    context.read<UserBloc>().add(
                                        InitializeUserSession());
                                  }
                                },
                              ),
                              BlocListener<UserBloc, UserState>(
                                listener: (context, state) {
                                  BlocStateTracker().updateState(
                                      'UserBloc', state);
                                  if (state is UserSessionLoaded) {
                                    context.read<VocabulaireUserBloc>().add(
                                        VocabulaireUserUpdate(userData: state.userData));
                                    }

                                },
                              ),
                              BlocListener<
                                  VocabulaireUserBloc,
                                  VocabulaireUserState>(
                                listener: (context, state) {
                                  if (state is ListPersoDeletionSuccess) {
                                    context.read<LeaderboardBloc>().add(
                                        FetchLeaderboard(local: LanguageUtils
                                            .getSmallCodeLanguage(
                                            context: context)));
                                    if (!testScreenShot) {
                                      context.read<NotificationBloc>().add(
                                          ShowNotification(
                                            message: getLocalizedSuccessMessage(
                                                context,
                                                "[SuccessBloc/vocabulaire_success_delete_list]"),
                                            backgroundColor: Colors.green,
                                          ));
                                    }
                                  }
                                  if (state is VocabulaireUserError) {
                                    context.read<NotificationBloc>().add(
                                        ShowNotification(
                                          message: getLocalizedErrorMessage(
                                              context, state.error),
                                          backgroundColor: Colors.red,
                                        ));
                                    context.read<VocabulaireUserBloc>().add(
                                        VocabulaireUserBlocErrorCleared());
                                  }
                                },
                              ),
                              BlocListener<NotificationBloc, NotificationState>(
                                listener: (context, state) {
                                  if (state is NotificationVisible) {
                                    WidgetsBinding.instance.addPostFrameCallback((
                                        _) {
                                      Future.delayed(
                                          const Duration(milliseconds: 50), () {
                                        final navigatorContext = navigatorKey
                                            .currentContext;
                                        if (navigatorContext != null &&
                                            context.mounted) {
                                          ScaffoldMessenger.of(navigatorContext)
                                            ..removeCurrentSnackBar()
                                            ..showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  state.message,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                backgroundColor: state
                                                    .backgroundColor,
                                                behavior: SnackBarBehavior
                                                    .floating,
                                                showCloseIcon: true,
                                                duration: const Duration(
                                                    seconds: 4),
                                              ),
                                            );
                                          context.read<NotificationBloc>().add(
                                              NotificationDismissed());
                                        }
                                      });
                                    });
                                  }
                                },
                              ),
                            ],
                            child: child ?? const SizedBox.shrink(),
                          );
                        }
                      )
                  );
                },
              )
              );
            },
          ),
        ),
      ),
    );
  }
}
