import 'dart:convert';
import 'dart:io'; // <-- AJOUTÉ pour File (même si on utilise les bytes, c'est une bonne pratique)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:image_picker/image_picker.dart';
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
  String? _newImageAvatarBase64;
  late Future<UserFirestore?> _userFuture; // <-- NOUVEAU: Variable pour stocker la Future

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    pseudoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // BONNE PRATIQUE: On charge les données une seule fois ici.
    _userFuture = LocalStorageService().loadUser();
  }

  void _initializeControllers(UserFirestore userProfile) {
    if (!_controllersInitialized) {
      pseudoController.text = userProfile.pseudo ?? '';
      _controllersInitialized = true;
    }
  }

  // <-- MODIFIÉ: La fonction accepte maintenant une `ImageSource`
  // pour savoir si elle doit ouvrir la galerie ou l'appareil photo.
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: source, // Utilise la source passée en paramètre
        imageQuality: 70,
        maxWidth: 500,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _newImageAvatarBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la sélection de l'image: $e")),
        );
      }
    }
  }

  // <-- NOUVEAU: La fonction qui affiche le menu de choix.
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop(); // Ferme le menu
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Appareil photo'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop(); // Ferme le menu
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationBloc = context.read<NotificationBloc>();
    return Center(
      child: FutureBuilder<UserFirestore?>(
        future: _userFuture, // <-- MODIFIÉ: On utilise la Future stockée
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("${context.loc.erreur_de_chargement_du_profil} ${snapshot.error}"));
          }

          if (snapshot.hasData) {
            final userProfile = snapshot.data!;
            _initializeControllers(userProfile);

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
                        clipBehavior: Clip.none,
                        children: [
                          if (imageToShow.isNotEmpty)
                            ClipOval(
                              child: Image.memory(
                                base64Decode(imageToShow),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Avatar(
                                    radius: 60,
                                    name: GetValidName(userProfile.pseudo),
                                    fontsize: 60,
                                  );
                                },
                              ),
                            )
                          else
                            Avatar(
                              radius: 60,
                              name: GetValidName(userProfile.pseudo),
                              fontsize: 60,
                            ),
                          Positioned(
                            bottom: -5,
                            right: -5,
                            child: GestureDetector(
                              // <-- MODIFIÉ: On appelle la fonction qui affiche le menu
                              onTap: () => _showImageSourceActionSheet(context),
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
                    const SizedBox(height: 25),
                    CustomTextField(
                      controller: pseudoController,
                      labelText: context.loc.login_pseudo,
                      hintText: context.loc.login_entrer_pseudo,
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          UpdateUserProfilEvent(
                            pseudo: pseudoController.text,
                            imageAvatar: _newImageAvatarBase64,
                          ),
                        );
                      },
                      child:  Text(context.loc.save),
                    )
                  ],
                ),
              ),
            );
          }
          return Center(child: Text("${context.loc.erreur_de_chargement_du_profil} ${snapshot.error}"));
        },
      ),
    );
  }
}
