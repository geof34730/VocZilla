// lib/ui/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_in_button/sign_in_button.dart';

import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/logic/blocs/auth/auth_event.dart';
import 'package:vobzilla/logic/blocs/auth/auth_state.dart';


import '../../theme/backgroundBlueLinear.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController languageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BackgroundBlueLinear(
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
                return Center(child: CircularProgressIndicator());
              }
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(labelText: 'First Name'),
                    ),
                    TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(labelText: 'Last Name'),
                    ),
                    TextField(
                      controller: languageController,
                      decoration: InputDecoration(labelText: 'Language'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(SignUpRequested(
                          email: emailController.text,
                          password: passwordController.text,
                          firstName: firstNameController.text,
                          lastName: lastNameController.text,
                          language: languageController.text,
                        ));
                      },
                      child: Text('Sign Up'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(SignInRequested(
                          email: emailController.text,
                          password: passwordController.text,
                        ));
                      },
                      child: Text('Sign In'),
                    ),
                    SignInButton(
                      text: "S'identifier avec Email",
                      Buttons.email,
                      onPressed: () {
                        context.read<AuthBloc>().add(GoogleSignInRequested());
                      },
                    ),

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
                  ],
                ),
              );
            },
        )
    );
  }
}
