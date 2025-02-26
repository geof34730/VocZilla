// lib/ui/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_in_button/sign_in_button.dart';

import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/logic/blocs/auth/auth_event.dart';
import 'package:vobzilla/logic/blocs/auth/auth_state.dart';


import '../../theme/backgroundBlueLinear.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController(text: "geoffrey.petain@gmail.com");
  final TextEditingController passwordController = TextEditingController(text:"Hefpccy\$08\$08");
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController languageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BackgroundBlueLinear(
        child:BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
           if (state is AuthError) {
             print(state.message);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top:100.00),
              child: Column(
                children: [
                  Text('Se connecter'),
                  TextField(

                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Mot de passe'),
                    obscureText: true,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(SignInRequested(
                        email: emailController.text,
                        password: passwordController.text,
                      ));
                    },
                    child: Text('Se connecter'),
                  ),

                  Text('Ou connectez-vous avec'),
                  SignInButton(
                    text: "S'identifier avec Google",
                    Buttons.google,
                    onPressed: () {
                      context.read<AuthBloc>().add(GoogleSignInRequested());
                    },
                  ),
                  SignInButton(
                    Buttons.facebook,
                    onPressed: () {
                      context.read<AuthBloc>().add(FacebookSignInRequested());
                    },
                  ),
                  SignInButton(
                    Buttons.apple,
                    onPressed: () {
                      //context.read<AuthBloc>().add(FacebookSignInRequested());
                    },
                  ),
                  Text("Vous n'avez pas de compte ?"),
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
