// lib/ui/screens/auth/register_screen.dart
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
import '../../../logic/blocs/notification/notification_bloc.dart';
import '../../../logic/blocs/notification/notification_event.dart';
import '../../backgroundBlueLinear.dart';
import '../../widget/elements/Error.dart';
import '../../widget/elements/Loading.dart';
import '../../widget/form/CustomPasswordField.dart';
import '../../widget/form/CustomTextField.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController emailController = TextEditingController();
  late final TextEditingController passwordController = TextEditingController();
  late final TextEditingController confirmPasswordController = TextEditingController();
  late final TextEditingController firstNameController = TextEditingController();
  late final TextEditingController lastNameController = TextEditingController();
  late final TextEditingController pseudoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    /*
    emailController = TextEditingController(text:"voczilla.test1@flutter-now.com");
    passwordController = TextEditingController(text:"Hefpccy%08%08");
    confirmPasswordController = TextEditingController(text:"Hefpccy%08%08");
    firstNameController = TextEditingController(text:"Geoffrey");
    lastNameController = TextEditingController(text:"Petain");
    pseudoController = TextEditingController(text:"GeofMix");*/
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    pseudoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundBlueLinear(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ErrorMessage(context:context, message:state.message);
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Loading();
            }
            // NOUVEAU: Ajout d'un Scaffold pour pouvoir afficher une SnackBar d'erreur
            // et d'un SingleChildScrollView pour éviter les problèmes de débordement
            // avec le clavier.
            return  Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(context.loc.login_sinscrire,
                            style: getFontForLanguage(
                              codelang: Localizations.localeOf(context).languageCode,
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                            )
                        ),
                      ),
                      CustomTextField(
                        controller: emailController,
                        labelText: context.loc.login_email,
                        hintText: context.loc.login_entrer_email,
                      ),
                      CustomPasswordField(
                        controller: passwordController,
                        labelText: context.loc.login_mot_de_passe,
                        hintText: context.loc.login_entrer_mot_de_passe,
                      ),
                      // NOUVEAU: Champ pour confirmer le mot de passe
                      CustomPasswordField(
                        controller: confirmPasswordController,
                        labelText: context.loc.login_confirmer_mot_de_passe, // À ajouter
                        hintText: context.loc.login_entrer_confirmer_mot_de_passe, // À ajouter
                      ),
                      CustomTextField(
                        controller: pseudoController,
                        labelText: context.loc.login_pseudo,
                        hintText: context.loc.login_entrer_pseudo,
                      ),
                      CustomTextField(
                        controller: firstNameController,
                        labelText: context.loc.login_prenom,
                        hintText: context.loc.login_entrer_prenom,
                      ),
                      CustomTextField(
                        controller: lastNameController,
                        labelText: context.loc.login_nom,
                        hintText: context.loc.login_entrer_nom,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:5.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            elevation: WidgetStateProperty.all(5),
                          ),
                          onPressed: () {
                            // NOUVEAU: Vérification que tous les champs sont remplis
                            if (emailController.text.trim().isEmpty ||
                                passwordController.text.isEmpty ||
                                confirmPasswordController.text.isEmpty ||
                                pseudoController.text.trim().isEmpty ||
                                firstNameController.text.trim().isEmpty ||
                                lastNameController.text.trim().isEmpty) {
                              context.read<NotificationBloc>().add(ShowNotification(
                                message: context.loc.login_tous_champs_obligatoires,
                                backgroundColor: Colors.red,
                              ));
                              return;
                            }
                            if (passwordController.text != confirmPasswordController.text) {
                              context.read<NotificationBloc>().add(ShowNotification(
                                message: context.loc.login_mots_de_passe_differents,
                                backgroundColor: Colors.red,
                              ));

                              return; // On arrête l'exécution ici
                            }

                            context.read<AuthBloc>().add(SignUpRequested(
                              email: emailController.text.trim(),
                              password: passwordController.text,
                              firstName: firstNameController.text.trim(),
                              lastName: lastNameController.text.trim(),
                              pseudo: pseudoController.text.trim(),
                            ));
                          },
                          child: Text(context.loc.login_sinscrire),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 5),
                        child: Text(context.loc.login_ou_inscrivez_vous_avec,
                            style: getFontForLanguage(
                              codelang: Localizations.localeOf(context).languageCode,
                              fontSize: 20,
                            )
                        ),
                      ),
                      SignInButton(
                        elevation: 5,
                        text: context.loc.login_avec_google,
                        Buttons.google,
                        onPressed: () {
                          context.read<AuthBloc>().add(GoogleSignInRequested());
                        },
                      ),
                      SizedBox(height: 10),
                      SignInButton(
                        elevation: 5,
                        text: context.loc.login_avec_facebook,
                        Buttons.facebook,
                        onPressed: () {
                          context.read<AuthBloc>().add(FacebookSignInRequested());
                        },
                      ),
                      SizedBox(height: 10),
                      if (!kIsWeb && (Platform.isIOS || Platform.isMacOS ))
                      SignInButton(
                        elevation: 5,
                        text: context.loc.login_avec_apple,
                        Buttons.apple,
                        onPressed: () {
                          context.read<AuthBloc>().add(AppleSignInRequested());
                        },
                      ),
                    ],
                  ),
            );
          },
        )
    );
  }
}
