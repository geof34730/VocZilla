import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';
import '../../../data/repository/auth_repository.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../backgroundBlueLinear.dart';

class ProfileEmailValidation extends StatelessWidget {
  ProfileEmailValidation({super.key});
  final AuthRepository _AuthRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    _AuthRepository.checkEmailVerifiedPeriodically(authBloc: authBloc);
    dynamic user;
    final authState = context.watch<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      user = authState.user;
    }
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && state.user!.emailVerified) {
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil( context,"/",(Route<dynamic> route) => false);
          }
        }
      },
      child: backgroundBlueLinear(
        context: context,
        child: Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      context.loc.email_validation_merci_register,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: GoogleFonts.titanOne().fontFamily,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "${context.loc.email_validation_msg_email_send} ${user.email}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      context.loc.email_validation_instruction,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      context.loc.email_validation_help,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      context.loc.email_validation_merci_register2,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        user.sendEmailVerification();
                      },
                      child: Text(context.loc.send_mail),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  }
}
