import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';
import '../../../data/repository/data_user_repository.dart';
import '../../widget/elements/Error.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repository/auth_repository.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../backgroundBlueLinear.dart';

class ProfileEmailValidation extends StatelessWidget {
  ProfileEmailValidation({super.key});
  final AuthRepository _AuthRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {

    Logger.Green.log("VERIFE EMAIL");
    final authBloc = BlocProvider.of<AuthBloc>(context);
    _AuthRepository.checkEmailVerifiedPeriodically(authBloc: authBloc);
    User? user;
    final authState = context.watch<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      user = authState.user;
    }

    if (user == null) {
      // This can happen if the auth state changes while this screen is visible.
      // We show a loading spinner, and the BlocListener should handle navigation.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Use a null-safe check on the user and emailVerified property.
        if (state is AuthAuthenticated && state.user?.emailVerified == true) {
          if (context.mounted) {
            DataUserRepository().emailVerifiedUpdateUserFirestore();
            Navigator.pushNamedAndRemoveUntil(
                context, "/", (Route<dynamic> route) => false);
          }
        }
      },
      child: BackgroundBlueLinear(
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
                      onPressed: () async {

                        try {
                          await user?.sendEmailVerification();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Email de vérification envoyé !"))
                          );
                        } catch (e) {
                          if (e is FirebaseAuthException && e.code == 'too-many-requests') {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Trop de demandes. Réessaie plus tard."))
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Erreur lors de l'envoi de l'email."))
                            );
                          }
                        }
                        /*
                        try {
                          // The user is guaranteed to be non-null here due to the check above.
                          await user.sendEmailVerification();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    context.loc.email_verification_sent)));
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          if (e is FirebaseAuthException && e.code == 'too-many-requests') {
                            ErrorMessage(
                                context: context,
                                message: context.loc.too_many_requests_error);
                          } else {
                            ErrorMessage(
                                context: context,
                                message: context.loc.error_sending_email);
                          }
                        }*/
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
