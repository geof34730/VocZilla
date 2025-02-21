import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vobzilla/global.dart';
import 'package:vobzilla/ui/screens/home_logout_screen.dart';
import 'package:vobzilla/ui/theme/theme.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationCubit, Locale>(
      builder: (context, locale) {
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
          home: HomeLogoutScreen(),
        );
      },
    );
  }
}
