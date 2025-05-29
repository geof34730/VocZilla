import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:vobzilla/global.dart';
import 'package:vobzilla/logic/blocs/auth/auth_event.dart';
import 'package:vobzilla/logic/blocs/vocabulaires/vocabulaires_state.dart';
import 'package:vobzilla/ui/theme/theme.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';
import 'app_route.dart';
import 'core/utils/device.dart';
import 'core/utils/logger.dart';
import 'data/repository/auth_repository.dart';
import 'data/repository/vocabulaire_user_repository.dart';
import 'data/services/localstorage_service.dart';
import 'data/services/vocabulaires_server_service.dart';
import 'l10n/app_localizations.dart';
import 'logic/blocs/BlocStateTracker.dart';
import 'logic/blocs/auth/auth_bloc.dart';
import 'logic/blocs/auth/auth_state.dart';
import 'logic/blocs/drawer/drawer_bloc.dart';
import 'logic/blocs/drawer/drawer_state.dart';
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
  MyApp({super.key});
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final AuthRepository _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: MultiBlocProvider(
        providers: [
          RepositoryProvider(create: (context) => LocalStorageService()),
          RepositoryProvider(create: (context) => VocabulaireServerService()),
          RepositoryProvider(create: (context) => VocabulaireUserRepository()),
          BlocProvider(create: (context) => AuthBloc(authRepository: _authRepository)..add(AppStarted())),
          BlocProvider(create: (context) => DrawerBloc()),
          BlocProvider(create: (context) => LocalizationCubit()),
          BlocProvider(create: (context) => PurchaseBloc()..add(LoadProducts())),
          BlocProvider(create: (context) => UserBloc()..add(CheckUserStatus())),
          BlocProvider(create: (context) => VocabulairesBloc()),
          BlocProvider(create: (context) => UpdateBloc()..add(CheckForUpdate())),
          BlocProvider(create: (context) => VocabulaireUserBloc()..add(CheckVocabulaireUserStatus())),
        ],
        child: BlocBuilder<LocalizationCubit, Locale>(
          builder: (context, locale) {
            FirebaseAuth.instance.setLanguageCode(locale.languageCode);
            return MaterialApp(
              theme: VobdzillaTheme.lightTheme,
              debugShowCheckedModeBanner: debugMode,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              onGenerateRoute: generateRoute,
              navigatorKey: navigatorKey,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final double screenWidth = constraints.maxWidth;
                    //final double targetWidth = isTablet(context:context) ? 750 : 450;
                    final double targetWidth = isTablet(context:context) ? 450 : 450;
                    final double scale = screenWidth / targetWidth;
                    final double screenHeight = constraints.maxHeight;
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: FittedBox(
                            alignment: Alignment.topLeft,
                            fit: BoxFit.fill,
                            child: SizedBox(
                              width: screenWidth / scale,
                              height: screenHeight / scale,
                              child: Builder(
                                builder: (context) {
                                  return MultiBlocListener(
                                    listeners: [
                                      BlocListener<AuthBloc, AuthState>(
                                        listener: (context, state) => BlocStateTracker().updateState('AuthBloc', state),
                                      ),
                                      BlocListener<DrawerBloc, DrawerState>(
                                        listener: (context, state) => BlocStateTracker().updateState('DrawerBloc', state),
                                      ),
                                      BlocListener<PurchaseBloc, PurchaseState>(
                                        listener: (context, state) => BlocStateTracker().updateState('PurchaseBloc', state),
                                      ),
                                      BlocListener<UpdateBloc, UpdateState>(
                                        listener: (context, state) => BlocStateTracker().updateState('UpdateBloc', state),
                                      ),
                                      BlocListener<UserBloc, UserState>(
                                        listener: (context, state) => BlocStateTracker().updateState('UserBloc', state),
                                      ),
                                      BlocListener<VocabulairesBloc, VocabulairesState>(
                                        listener: (context, state) {
                                          Logger.Yellow.log("VocabulairesBloc state: $state");
                                          BlocStateTracker().updateState('VocabulairesBloc', state);
                                        },
                                      ),
                                      BlocListener<VocabulaireUserBloc, VocabulaireUserState>(
                                        listener: (context, state) {
                                          Logger.Yellow.log("VocabulairesUserBloc state: $state");
                                          BlocStateTracker().updateState('VocabulaireUserBloc', state);
                                        },
                                      ),
                                    ],
                                    child: child ?? const SizedBox.shrink(),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
