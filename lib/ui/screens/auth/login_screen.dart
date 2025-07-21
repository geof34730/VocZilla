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
import '../../../core/utils/ui.dart';
import '../../backgroundBlueLinear.dart';
import '../../widget/form/CustomPasswordField.dart';
import '../../widget/form/CustomTextField.dart';

// MODIFICATION : Conversion en StatefulWidget
class LoginScreen extends StatefulWidget {
  // On accepte un message d'erreur optionnel
  final String? errorMessage;

  const LoginScreen({super.key, this.errorMessage});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController(text: 'geoffrey.petain@gmail.com');
  final TextEditingController passwordController = TextEditingController(text: "Hefpccy%08%08");

  @override
  void initState() {
    super.initState();
    // Si un message d'erreur a été passé au widget...
    if (widget.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // On vérifie que le widget est toujours dans l'arbre.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.errorMessage!, style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundBlueLinear(
      child: Center(
        // MODIFICATION : On retire le BlocConsumer, la gestion d'erreur est dans initState.
        // On peut garder un BlocListener pour les états de chargement si besoin.
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoading) {
              // Optionnel : afficher un dialogue de chargement
            }
          },
          child: Padding(
            key: const ValueKey('login_screen'),
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(context.loc.login_se_connecter,
                        style: TextStyle(
                            fontSize: 25,
                            fontFamily: GoogleFonts.titanOne().fontFamily)),
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
                    padding: const EdgeInsets.only(top: 5.0),
                    child: ElevatedButton(
                      key: const ValueKey('validate_login_button'),
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(5),
                      ),
                      onPressed: () {
                        context.read<AuthBloc>().add(SignInRequested(
                          email: emailController.text,
                          password: passwordController.text,
                        ));
                      },
                      child: Text(context.loc.login_se_connecter),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 5),
                    child: Text(context.loc.login_ou_connecter_vous_avec,
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: GoogleFonts.titanOne().fontFamily)),
                  ),
                  SignInButton(
                    elevation: 5,
                    text: context.loc.login_avec_google,
                    Buttons.google,
                    onPressed: () {
                      context.read<AuthBloc>().add(GoogleSignInRequested());
                    },
                  ),
                  SignInButton(
                    elevation: 5,
                    text: context.loc.login_avec_facebook,
                    Buttons.facebook,
                    onPressed: () {
                      context.read<AuthBloc>().add(FacebookSignInRequested());
                    },
                  ),
                  if (!kIsWeb && Platform.isIOS)
                    SignInButton(
                      elevation: 5,
                      text: context.loc.login_avec_apple,
                      Buttons.apple,
                      onPressed: () {
                        context.read<AuthBloc>().add(AppleSignInRequested());
                      },
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 5),
                    child: Text(context.loc.login_no_compte,
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: GoogleFonts.titanOne().fontFamily)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(context.loc.login_inscrivez_vous),
                  ),
                  FutureBuilder<String>(
                    future: getAppVersion(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Erreur version', style: TextStyle(color: Colors.red));
                      } else {
                        return Text('Version : ${snapshot.data}', style: TextStyle(color: Colors.grey));
                      }
                    },
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
