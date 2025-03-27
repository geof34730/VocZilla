import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/repository/auth_repository.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../theme/backgroundBlueLinear.dart';

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
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/",
                  (Route<dynamic> route) => false,
            );
          }
        }
      },
      child: BackgroundBlueLinear(
        context: context,
        child: Center(
          child: SingleChildScrollView(
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
                      "Merci de vous être inscrit ! ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: GoogleFonts.titanOne().fontFamily,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Un email de vérification a été envoyé à votre adresse email. ${user.email}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Veuillez vérifier votre boîte de réception et suivre les instructions pour valider votre adresse email. Cela nous permettra de confirmer votre inscription et de vous donner accès à toutes les fonctionnalités de notre service.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Si vous ne voyez pas l'email dans votre boîte de réception, pensez à vérifier votre dossier de spam ou de courriers indésirables.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Merci de votre confiance !",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        print("send email");
                        user.sendEmailVerification();
                      },
                      child: Text("Recevoir un nouvel email de vérification"),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
