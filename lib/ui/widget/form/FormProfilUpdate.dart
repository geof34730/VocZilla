import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

import 'CustomTextField.dart';

class FormProfilUpdate extends StatefulWidget {
  const FormProfilUpdate({super.key});

  @override
  State<FormProfilUpdate> createState() => _FormProfilUpdateState();
}

class _FormProfilUpdateState extends State<FormProfilUpdate> {
  final TextEditingController pseudoController = TextEditingController();

  bool _controllersInitialized = false;
  String? _newImageAvatarBase64;
  Uint8List? _imageToShowBytes;
  bool _isSubmitting = false;
  late Future<UserFirestore?> _userFuture;

  @override
  void dispose() {
    pseudoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _userFuture = LocalStorageService().loadUser();
  }

  void _initializeState(UserFirestore userProfile) {
    if (!_controllersInitialized) {
      pseudoController.text = userProfile.pseudo ?? '';
      if (userProfile.imageAvatar.isNotEmpty) {
        try {
          _imageToShowBytes = base64Decode(userProfile.imageAvatar);
        } catch (e) {
          _imageToShowBytes = null;
        }
      }
      _controllersInitialized = true;
    }
  }

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
          _imageToShowBytes = bytes;
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
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Appareil photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImage(ImageSource.camera);
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
    return Center(
      child: FutureBuilder<UserFirestore?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("${context.loc.erreur_de_chargement_du_profil} ${snapshot.error}"));
          }

          if (snapshot.hasData) {
            final userProfile = snapshot.data!;
            _initializeState(userProfile);

            return BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                // On réinitialise l'état de soumission dès qu'on reçoit un nouvel état du BLoC,
                // ce qui signifie que l'opération est terminée (succès ou échec).
                if (mounted) {
                  setState(() {
                    _isSubmitting = false;
                  });
                }

                if (state is AuthAuthenticated) {
                  Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Peut être const
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
                          if (_imageToShowBytes != null)
                            ClipOval(
                              child: Image.memory(
                                _imageToShowBytes!,
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
                              onTap: _isSubmitting ? null : () => _showImageSourceActionSheet(context),
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
                      onPressed: _isSubmitting ? null : () {
                        setState(() {
                          _isSubmitting = true;
                        });
                        context.read<AuthBloc>().add(UpdateUserProfilEvent(
                          pseudo: pseudoController.text,
                          imageAvatar: _newImageAvatarBase64,
                        ));
                      },
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            )
                          : Text(context.loc.save),
                    ),
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
