import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:image_picker/image_picker.dart'; // <-- 1. AJOUTER CET IMPORT
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/data/models/user_firestore.dart';
import 'package:vobzilla/data/services/localstorage_service.dart';
import '../../../core/utils/string.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../../logic/blocs/notification/notification_bloc.dart';

import 'CustomTextField.dart';

class FormProfilUpdate extends StatefulWidget {
  const FormProfilUpdate({super.key});

  @override
  State<FormProfilUpdate> createState() => _FormProfilUpdateState();
}

class _FormProfilUpdateState extends State<FormProfilUpdate> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController pseudoController = TextEditingController();

  bool _controllersInitialized = false;
  String? _newImageAvatarBase64; // Pour stocker la nouvelle image choisie

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

  // Fonction pour sélectionner une image depuis la galerie
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compresser l'image pour optimiser
        maxWidth: 500,   // Redimensionner pour ne pas stocker d'images trop grandes
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _newImageAvatarBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      // Gérer les erreurs (ex: permissions refusées)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la sélection de l'image.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationBloc = context.read<NotificationBloc>();
    return Center(
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

            // Utilise la nouvelle image si elle existe, sinon celle du profil
            final imageToShow = _newImageAvatarBase64 ?? userProfile.imageAvatar;

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
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        fit: StackFit.expand,
                        clipBehavior: Clip.none, // Permet au bouton de déborder légèrement
                        children: [
                          // Widget principal de l'avatar
                          if (imageToShow.isNotEmpty)
                            ClipOval(
                              child: Image.memory(
                                base64Decode(imageToShow),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback si le décodage de l'image échoue
                                  return Avatar(
                                    radius: 60,
                                    name: GetValidName(userProfile.pseudo),
                                    fontsize: 60,
                                  );
                                },
                              ),
                            )
                          else
                          // Fallback si aucune image n'est disponible
                            Avatar(
                              radius: 60, // Taille corrigée
                              name: GetValidName(userProfile.pseudo),
                              fontsize: 60, // Taille de police corrigée
                            ),

                          // Bouton d'édition
                          Positioned(
                            bottom: -5,
                            right: -5,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 2,
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25), // Espace ajouté après l'avatar
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
                            imageAvatar: _newImageAvatarBase64,
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
    );
  }
}
