import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/data/models/user_firestore.dart'; // <-- Importer le modèle
import 'package:vobzilla/data/services/localstorage_service.dart'; // <-- Importer le service
import '../../../core/utils/logger.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../../logic/blocs/notification/notification_bloc.dart';
import '../../backgroundBlueLinear.dart';
import '../../widget/form/CustomTextField.dart';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final TextEditingController firstNameController = TextEditingController(text:'coucou');
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController pseudoController = TextEditingController();

  bool _controllersInitialized = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    pseudoController.dispose();
    super.dispose();
  }

  void _initializeControllers(UserFirestore userProfile) {
    if (!_controllersInitialized) {
      firstNameController.text = userProfile.firstName;
      lastNameController.text = userProfile.lastName;
      pseudoController.text = userProfile.pseudo;
      _controllersInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationBloc = context.read<NotificationBloc>();
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
     Center(

             child: FutureBuilder<UserFirestore?>(
                future: LocalStorageService().loadUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Erreur de chargement du profil: ${snapshot.error}"));
                  }

                  if (snapshot.hasData) {
                    final userProfile = snapshot.data!;
                    _initializeControllers(userProfile);

                    return BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthAuthenticated) {
                          Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
                        }

                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Mettre à jour votre profil",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontFamily: GoogleFonts.titanOne().fontFamily)),

                            CustomTextField(
                              controller: pseudoController,
                              labelText: context.loc.login_pseudo,
                              hintText: context.loc.login_entrer_pseudo,
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
                            const SizedBox(height: 20),
                            ElevatedButton(
                                  onPressed: () {
                                    context.read<AuthBloc>().add(
                                      UpdateUserProfilEvent(
                                        firstName: firstNameController.text,
                                        lastName: lastNameController.text,
                                        pseudo: pseudoController.text,
                                        notificationBloc: notificationBloc,
                                      ),
                                    );
                                  },
                                  child: const Text("Enregistrer"),
                                )

                          ],
                        ),
                      ),
                    );
                  }

                  return Center(child: Text("Erreur de chargement du profil: ${snapshot.error}"));
                },
              ),
    )
      ]
    );
  }
}

