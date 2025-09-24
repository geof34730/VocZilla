import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/global.dart';

import '../../core/utils/device.dart';
import '../../core/utils/errorMessage.dart';
import '../../core/utils/getFontForLanguage.dart';
import '../../core/utils/logger.dart';
import '../../data/repository/vocabulaire_user_repository.dart';
import '../../logic/blocs/auth/auth_bloc.dart';
import '../../logic/blocs/auth/auth_event.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../theme/appColors.dart';
import '../backgroundBlueLinear.dart';
import '../widget/elements/Error.dart';

class HomeLogoutScreen extends StatefulWidget {
  const HomeLogoutScreen({super.key});

  @override
  State<HomeLogoutScreen> createState() => _HomeLogoutScreenState();
}

class _HomeLogoutScreenState extends State<HomeLogoutScreen> {
  bool _isLoading = false;

  Future<void> _signInAsGuest() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      // 1. Récupérer l'identifiant de l'appareil
      String? deviceId;
      if (testScreenShot) {
        deviceId = "DeviceTest-546684643131";
      } else {
        deviceId = await getPlatformDeviceId();
      }
      if (deviceId == null) {
        throw Exception("Impossible de récupérer un identifiant valide pour l'appareil.");
      }
      Logger.Green.log('Device ID récupéré = $deviceId');

      // 2. Appeler la Cloud Function
      final callable = functions.httpsCallable('signInOrRegisterWithDevice');
      final parameters = <String, dynamic>{'deviceId': deviceId};

      Logger.Yellow.log('Envoi des paramètres à la Cloud Function: $parameters');
      final res = await callable.call(parameters);

      final String token = (res.data as Map)['customToken'] as String;

      // 3. Se connecter à Firebase
      final UserCredential cred = await FirebaseAuth.instance.signInWithCustomToken(token);
      final user = cred.user;
      if (user == null) {
        throw Exception("Firebase a renvoyé un user null après signInWithCustomToken");
      }
      debugPrint('Connexion OK avec UID = ${user.uid}');

      if (mounted) {
        context.read<AuthBloc>().add(AuthLoggedIn(user));

      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Erreur Cloud Function [${e.code}]: ${e.message}');
      if (mounted) {
        final message = getLocalizedErrorMessage(context, '[firebase_functions/${e.code}] ${e.message}');
        ErrorMessage(context: context, message: message);
      }
    } catch (e, s) {
      debugPrint('Erreur auth: $e\n$s');
      if (mounted) {
        final message = getLocalizedErrorMessage(context, e.toString());
        ErrorMessage(context: context, message: message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final codelang = Localizations.localeOf(context).languageCode;
    final baseStyle = Theme.of(context).textTheme.bodyMedium;

    return Scaffold(
      body: SafeArea(
        child: BackgroundBlueLinear(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/brand/logo_landing.png"),
                  // TitleSite(typoSize: 80),

                  Text(
                    context.loc.home_notlogged_accroche1,
                    style: getFontForLanguage(
                      codelang: codelang,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),

                  Text(
                    context.loc.home_notlogged_accroche2,
                    style: getFontForLanguage(
                      codelang: codelang,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: getFontForLanguage(
                        codelang: codelang,
                        fontSize: 14,
                      ).copyWith(
                        color: baseStyle?.color,
                      ),
                      children: <TextSpan>[
                        TextSpan(text: context.loc.home_notlogged_accroche3),
                        TextSpan(
                          text: context.loc.home_notlogged_accroche4,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ", ${context.loc.home_notlogged_accroche5}",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  Text(
                    "📈 ${context.loc.home_notlogged_accroche6}",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "🎯 ${context.loc.home_notlogged_accroche7}",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "🧠 ${context.loc.home_notlogged_accroche8}",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    context.loc.home_notlogged_accroche9,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    key: ValueKey('link_home_login'),
                    onPressed: _isLoading ? null : _signInAsGuest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : Text(
                      context.loc.home_notlogged_button_go,
                      style: getFontForLanguage(
                        codelang: codelang,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    key: ValueKey('test_share'),
                    onPressed: (){
                      Navigator.pushReplacementNamed(context, "/share/6dba61f6-6607-4ed5-9a74-70e8bb6bbfc0");
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child:  Text(
                      "test share 6dba61f6-6607-4ed5-9a74-70e8bb6bbfc0",
                      style: getFontForLanguage(
                        codelang: codelang,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
