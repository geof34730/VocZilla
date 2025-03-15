import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_button/sign_in_button.dart';

import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/logic/blocs/auth/auth_event.dart';
import 'package:vobzilla/logic/blocs/auth/auth_state.dart';


import '../../theme/backgroundBlueLinear.dart';
import '../../widget/elements/Error.dart';
import '../../widget/elements/Loading.dart';
import '../../widget/form/CustomPasswordField.dart';
import '../../widget/form/CustomTextField.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final TextEditingController emailController = TextEditingController(text: 'geoffrey.petain@gmail.com');
  final TextEditingController passwordController = TextEditingController(text:"sdfsdfs@ddd-df");

  @override
  Widget build(BuildContext context) {
    return BackgroundBlueLinear(
        context: context,
        child:BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ErrorMessage(context:context, message:state.message);
            }
            if (state is AuthLoading) {
               Loading();
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text("Se connecter",
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
                  Padding(
                  padding: EdgeInsets.only(top:5.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: WidgetStateProperty.all(5),
                    ),
                          onPressed: () {
                            //FirebaseAuth.instance.setLanguageCode('fr');
                            context.read<AuthBloc>().add(SignInRequested(
                              email: emailController.text,
                              password: passwordController.text,
                            ));
                          },
                          child: Text('Se connecter'),
                        ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0, bottom: 5),
                    child: Text("Ou connectez-vous avec",
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: GoogleFonts.titanOne().fontFamily)),
                  ),
                  SignInButton(
                    elevation: 5,
                    text: "Avec Google",
                    Buttons.google,
                    onPressed: () {
                      context.read<AuthBloc>().add(GoogleSignInRequested());
                    },
                  ),
                  SignInButton(
                    elevation: 5,
                    text: "Avec Facebook",
                    Buttons.facebook,
                    onPressed: () {
                      context.read<AuthBloc>().add(FacebookSignInRequested());
                    },
                  ),
                  if (Platform.isIOS)
                          SignInButton(
                            elevation: 5,
                            text: "Avec Apple",
                            Buttons.apple,
                            onPressed: () {
                              context.read<AuthBloc>().add(AppleSignInRequested());
                            },
                          ),

                  Padding(
                    padding: EdgeInsets.only(top: 20.0,bottom: 5),
                    child: Text("Vous n'avez pas de compte ?",
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: GoogleFonts.titanOne().fontFamily)),
                  ),


                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text('Inscrivez-vous'),
                  ),
                ],
              ),
            );
          },
        )
    );
  }
}
