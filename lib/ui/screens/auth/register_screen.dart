// lib/ui/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:vobzilla/core/utils/localization.dart';

import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/logic/blocs/auth/auth_event.dart';
import 'package:vobzilla/logic/blocs/auth/auth_state.dart';


import '../../backgroundBlueLinear.dart';
import '../../widget/elements/Error.dart';
import '../../widget/elements/Loading.dart';
import '../../widget/form/CustomPasswordField.dart';
import '../../widget/form/CustomTextField.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});
  final TextEditingController emailController = TextEditingController(text: 'geoffrey.petain@gmail.com');
  final TextEditingController passwordController = TextEditingController(text:"sdfsdfs@ddd-df");
  final TextEditingController firstNameController = TextEditingController(text: 'John');
  final TextEditingController lastNameController = TextEditingController(text: 'Doe');

  @override
  Widget build(BuildContext context) {
    return BackgroundBlueLinear(

        child: BlocConsumer<AuthBloc, AuthState>(
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(context.loc.login_sinscrire,
                          style: TextStyle(
                              fontSize: 25,
                              fontFamily: GoogleFonts.titanOne().fontFamily)
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
                        child: Text(context.loc.login_sinscrire),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 5),
                      child: Text(context.loc.login_ou_inscrivez_vous_avec,
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: GoogleFonts.titanOne().fontFamily
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
                    SignInButton(
                      elevation: 5,
                      text: context.loc.login_avec_facebook,
                      Buttons.facebook,
                      onPressed: () {
                        context.read<AuthBloc>().add(FacebookSignInRequested());
                      },
                    ),
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
