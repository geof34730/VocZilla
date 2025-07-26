// lib/ui/screens/auth/login_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/logic/blocs/auth/auth_event.dart';
import 'package:vobzilla/logic/blocs/auth/auth_state.dart';
import '../../../core/utils/getFontForLanguage.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/ui.dart';
import '../../backgroundBlueLinear.dart';
import '../../widget/elements/Error.dart';
import '../../widget/form/CustomPasswordField.dart';
import '../../widget/form/CustomTextField.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //final TextEditingController emailController = TextEditingController(text: "voczilla.test2@flutter-now.com");
  //final TextEditingController passwordController = TextEditingController(text: "Hefpccy%08%08");
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final codelang = Localizations.localeOf(context).languageCode;
    return BackgroundBlueLinear(
      child: Center(
        child: Padding(
              key: const ValueKey('login_screen'),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(context.loc.login_se_connecter,
                          style: getFontForLanguage(
                            codelang: codelang,
                            fontSize: 25,
                          ),
                      )
                    ),
                    CustomTextField(
                      keyForShoot: 'login_field',
                      controller: emailController,
                      labelText: context.loc.login_email,
                      hintText: context.loc.login_entrer_email,
                    ),
                    CustomPasswordField(
                      keyForShoot: "password_field",
                      controller: passwordController,
                      labelText: context.loc.login_mot_de_passe,
                      hintText: context.loc.login_entrer_mot_de_passe,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton(
                        key: const ValueKey('validate_login_button'),
                        style: ButtonStyle(
                          elevation: WidgetStateProperty.all(5),
                        ),
                        onPressed: () {
                          context.read<AuthBloc>().add(SignInRequested(
                            email: emailController.text.trim(),
                            password: passwordController.text,
                          ));
                        },
                        child: Text(
                            context.loc.login_se_connecter,
                            style: getFontForLanguage(
                                codelang: codelang,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 5),
                      child: Text(context.loc.login_ou_connecter_vous_avec,
                          style: getFontForLanguage(
                            codelang: codelang,
                            fontSize: 20,
                          ),
                       ),
                    ),
                    Opacity(
                      opacity:  1.0,
                      child: SignInButton(
                        elevation: 5,
                        text: context.loc.login_avec_google,
                        Buttons.google,
                        onPressed:  () {
                          context.read<AuthBloc>().add(GoogleSignInRequested());
                        },
                      ),
                    ),
                    Opacity(
                      opacity:  1.0,
                      child: SignInButton(
                        elevation: 5,
                        text: context.loc.login_avec_facebook,
                        Buttons.facebook,
                        onPressed:  () {
                          context.read<AuthBloc>().add(FacebookSignInRequested());
                        },
                      ),
                    ),
                    if (!kIsWeb && Platform.isIOS)
                      Opacity(
                        opacity:  1.0,
                        child: SignInButton(
                          elevation: 5,
                          text: context.loc.login_avec_apple,
                          Buttons.apple,
                          onPressed:  () {
                            context.read<AuthBloc>().add(AppleSignInRequested());
                          },
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 5),
                      child: Text(context.loc.login_no_compte,
                            style: getFontForLanguage(
                              codelang: codelang,
                              fontSize: 20,
                            ),
                         ),
                    ),
                    ElevatedButton(
                      onPressed:  () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                          context.loc.login_inscrivez_vous,
                          style: getFontForLanguage(
                            codelang: codelang,

                          ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    /*FutureBuilder<String>(
                      future: getAppVersion(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text('Version : ${snapshot.data}', style: const TextStyle(color: Colors.grey));
                        }
                        return const SizedBox.shrink();
                      },
                    ),*/
                  ],
                ),
              ),
            )
      )
    );
  }
}
