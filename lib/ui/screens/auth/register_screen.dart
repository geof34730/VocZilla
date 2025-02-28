// lib/ui/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_button/sign_in_button.dart';

import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/logic/blocs/auth/auth_event.dart';
import 'package:vobzilla/logic/blocs/auth/auth_state.dart';


import '../../theme/backgroundBlueLinear.dart';
import '../../widget/form/CustomPasswordField.dart';
import '../../widget/form/CustomTextField.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController(text: 'sdsdfds@sdfds.fr');
  final TextEditingController passwordController = TextEditingController(text:"sdfsdfsdf");
  final TextEditingController firstNameController = TextEditingController(text: 'John');
  final TextEditingController lastNameController = TextEditingController(text: 'Doe');


  @override
  Widget build(BuildContext context) {
    return BackgroundBlueLinear(
        context: context,
        child:BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                // Navigate to home screen
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                return Center(child: CircularProgressIndicator());
              }
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text("S'inscrire",
                          style: TextStyle(
                              fontSize: 25,
                              fontFamily: GoogleFonts.titanOne().fontFamily)),
                    ),
                    CustomTextField(
                      controller: emailController,
                      labelText: 'Email',
                      hintText: 'Entrez votre email',
                    ),
                    CustomPasswordField(
                      controller: passwordController,
                      labelText: 'Mot de passe',
                      hintText: 'Entrez votre mot de passe',
                    ),
                    CustomTextField(
                      controller: firstNameController,
                      labelText: 'Prénom',
                      hintText: 'Entrez votre prénom',
                    ),
                    CustomTextField(
                      controller: lastNameController,
                      labelText: 'Nom',
                      hintText: 'Entrez votre nom',
                    ),
                    Padding(
                      padding: EdgeInsets.only(top:5.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          elevation: WidgetStateProperty.all(5),
                        ),
                        onPressed: () {
                          context.read<AuthBloc>().add(SignUpRequested(
                            email: emailController.text,
                            password: passwordController.text,
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                          ));
                        },
                        child: Text("S'inscrire"),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 5),
                      child: Text("Ou inscrivez-vous avec",
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: GoogleFonts.titanOne().fontFamily)),
                    ),
                    SignInButton(
                      elevation: 5,
                      text: "S'identifier avec Google",
                      Buttons.google,
                      onPressed: () {
                        context.read<AuthBloc>().add(GoogleSignInRequested());
                      },
                    ),
                    SignInButton(
                      elevation: 5,
                      text: "S'identifier avec Facebook",
                      Buttons.facebook,
                      onPressed: () {
                        context.read<AuthBloc>().add(FacebookSignInRequested());
                      },
                    ),
                    SignInButton(
                      elevation: 5,
                      text: "S'identifier avec Apple",
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
