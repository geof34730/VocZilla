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
import '../../widget/elements/Error.dart';
import '../../widget/elements/Loading.dart';
import '../../widget/form/CustomPasswordField.dart';
import '../../widget/form/CustomTextField.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
 // final TextEditingController emailController = TextEditingController(text: 'geoffrey.petain@gmail.com');
 // final TextEditingController passwordController = TextEditingController(text:"sdfsdfs@ddd-df");
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BackgroundBlueLinear(
        child: Center(
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
              key: ValueKey('login_screen'),
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
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
                  padding: EdgeInsets.only(top:5.0),
                  child: ElevatedButton(
                    key: ValueKey('validate_login_button'),
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
                          child: Text(context.loc.login_se_connecter),
                        ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0, bottom: 5),
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
                  if(!kIsWeb)
                  if (Platform.isIOS)
                          SignInButton(
                            elevation: 5,
                            text: context.loc.login_avec_apple,
                            Buttons.apple,
                            onPressed: () {
                              context.read<AuthBloc>().add(AppleSignInRequested());
                            },
                          ),

                  Padding(
                    padding: EdgeInsets.only(top: 20.0,bottom: 5),
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
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Center(child:Text('Erreur lors de la récupération du numéro de build',style: TextStyle(color: Colors.red)));
                      } else {
                        return Center(child:Text('Version : ${snapshot.data}',style: TextStyle(color:Colors.grey),));
                      }
                    },
                  ),
                  /*
                  FutureBuilder<String>(
                    future: getPackageName(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Center(child:Text('Erreur lors de la récupération du numéro de build',style: TextStyle(color: Colors.red)));
                      } else {
                        return Center(child:Text('name : ${snapshot.data}',style: TextStyle(color:Colors.grey),));
                      }
                    },
                  )*/
                ],
              ),
            );
          },
        ))
    );
  }
}
