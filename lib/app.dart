import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vobzilla/global.dart';
import 'package:vobzilla/logic/blocs/auth/auth_event.dart';
import 'package:vobzilla/ui/theme/theme.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';

import 'app_route.dart';
import 'data/repository/auth_repository.dart';
import 'logic/blocs/auth/auth_bloc.dart';
import 'logic/blocs/auth/auth_state.dart';
import 'logic/blocs/drawer/drawer_bloc.dart';
import 'logic/blocs/purchase/purchase_bloc.dart';
import 'logic/blocs/purchase/purchase_event.dart';
import 'logic/blocs/user/user_bloc.dart';
import 'logic/blocs/user/user_event.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final Route Function(RouteSettings settings) generateRoute=AppRoute.generateRoute;
  final AuthRepository _authRepository = AuthRepository();
  @override
  Widget build(BuildContext context) {
    return Material(
        child:MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authRepository: _authRepository)..add(AppStarted()),
        ),
        BlocProvider(
            create: (context) => DrawerBloc()
        ),
        BlocProvider(
            create: (context) => LocalizationCubit()
        ),
        BlocProvider(
          create: (context) => PurchaseBloc()..add(LoadProducts()),
        ),
        BlocProvider(
          create: (context) => UserBloc()..add(CheckUserStatus()),
        )
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
                return Builder(
                  builder: (context) {
                    return BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                      },
                      child: child ?? Container(),
                    );
                  },
                );
              },
            );
          },
        ),
     )
    );
  }
}
