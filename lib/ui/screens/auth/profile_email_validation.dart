// /lib/ui/screens/auth/profile_email_validation.dart

import 'dart:async'; // Importation nécessaire pour le Timer

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/logic/blocs/notification/notification_bloc.dart';
import 'package:vobzilla/logic/blocs/notification/notification_event.dart';
import '../../../core/utils/getFontForLanguage.dart';
import '../../../core/utils/logger.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_event.dart'; // Importez vos événements
import '../../../logic/blocs/auth/auth_state.dart';
import '../../backgroundBlueLinear.dart';

class ProfileEmailValidation extends StatefulWidget {
  const ProfileEmailValidation({super.key});

  @override
  State<ProfileEmailValidation> createState() => _ProfileEmailValidationState();
}

class _ProfileEmailValidationState extends State<ProfileEmailValidation> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // On démarre un timer qui va vérifier le statut toutes les 3 secondes.
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        // Il est crucial de rafraîchir l'utilisateur pour obtenir le dernier statut.
        await FirebaseAuth.instance.currentUser?.reload();
        final user = FirebaseAuth.instance.currentUser;
        Logger.Green.log("TIMER: ${user?.emailVerified ?? false}");
        // Si l'email est vérifié et que le widget est toujours affiché.
        if (user?.emailVerified ?? false) {
          // On a trouvé que l'utilisateur est vérifié, on arrête le timer.
          timer.cancel();

          // On notifie l'AuthBloc. Le BLoC mettra à jour Firestore et l'état.
          if (mounted) {
            // CORRECTION : On instancie la classe d'événement directement.
            context.read<AuthBloc>().add(EmailVerifiedEvent());
          }
        }
      } catch (e) {
        // Gère les erreurs possibles (ex: l'utilisateur a été supprimé).
        Logger.Red.log("Erreur pendant la vérification de l'email: $e");
        timer.cancel(); // Arrête le timer en cas d'erreur pour éviter les boucles.
      }
    });
  }

  @override
  void dispose() {
    // Toujours annuler les timers dans dispose pour éviter les fuites de mémoire.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Logger.Green.log("Building ProfileEmailValidation Screen");

    final authState = context.watch<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userProfile = authState.userProfile;

    // Votre BlocListener existant est parfait. Il réagira au nouvel état
    // émis par le BLoC une fois la vérification détectée.
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && state.userProfile.isEmailVerified) {
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, "/", (Route<dynamic> route) => false);
          }
        }
      },
      child: BackgroundBlueLinear(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.loc.email_validation_merci_register,
                    textAlign: TextAlign.center,
                    style: getFontForLanguage(
                      codelang: Localizations.localeOf(context).languageCode,
                      fontSize: 30,
                    )

                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${context.loc.email_validation_msg_email_send} ${userProfile.email}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.loc.email_validation_instruction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.loc.email_validation_help,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.loc.email_validation_merci_register2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.currentUser
                            ?.sendEmailVerification();
                        context.read<NotificationBloc>().add(ShowNotification(
                            message: "Email de vérification envoyé !",
                            backgroundColor: Colors.green));
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'too-many-requests') {
                          context.read<NotificationBloc>().add(ShowNotification(
                              message:
                              "Trop de demandes. Réessayez plus tard.",
                              backgroundColor: Colors.orange));
                        } else {
                          context.read<NotificationBloc>().add(ShowNotification(
                              message: "Erreur lors de l'envoi de l'email.",
                              backgroundColor: Colors.red));
                        }
                      } catch (e) {
                        context.read<NotificationBloc>().add(ShowNotification(
                            message: "Une erreur inconnue est survenue.",
                            backgroundColor: Colors.red));
                      }
                    },
                    child: Text(context.loc.send_mail),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
