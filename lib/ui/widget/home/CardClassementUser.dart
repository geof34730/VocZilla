import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/multi_segment_linear_indicator.dart';
import '../../../data/models/user_firestore.dart';
import '../../../data/services/localstorage_service.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../statistical/LevelChart.dart';

class CardClassementUser extends StatelessWidget {

  final int position;

  const CardClassementUser({
    super.key,
    required this.position,


  });


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
       return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated ) {
            final user = state.userProfile;
            return FutureBuilder<UserFirestore?>(
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
                    final String pseudo = userProfile.pseudo;
                    final int daysSinceCreation = userProfile.createdAt != null
                        ? DateTime.now().difference(userProfile.createdAt!).inDays
                        : 0;
                    return Card(
                        color: Colors.deepPurple,
                        child: ListTile(
                          leading:
                          userProfile.imageAvatar != ''
                              ?
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              // La couleur de fond sera visible si l'image n'est pas carrée
                              color: Colors.blue.shade700,
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.memory(
                              base64Decode(userProfile.imageAvatar),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Avatar(
                                  radius: 40,
                                  name: _getValidName(pseudo),
                                  fontsize: 30,
                                );
                              },
                            ),
                          )
                              :
                          Avatar(
                            radius: 40,
                            name: _getValidName(pseudo),
                            fontsize: 30,
                          ),
                          title:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  SizedBox(width: 8), // Ajoutez un espacement entre l'avatar et le texte
                                  Expanded(
                                    child: Text(
                                      pseudo,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontFamily: GoogleFonts.titanOne().fontFamily,
                                      ),
                                    ),
                                  ),
                                  Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            '$daysSinceCreation jour(s)',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,

                                            )
                                        ),

                                      ]
                                  ),
                                ],
                              ),
                              Padding(
                                  padding: EdgeInsetsGeometry.only(bottom: 3),
                                  child:AutoSizeText(
                                    position.toString(),
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.white,
                                        fontFamily: GoogleFonts.titanOne().fontFamily
                                    ),
                                    maxLines: 1,
                                    minFontSize: 30,
                                  )
                              )
                            ],
                          ),
                        )
                    );

                  }
                  return const Center(child: CircularProgressIndicator());
                }
            );
          }

          return const Center(child: CircularProgressIndicator());
          //return SizedBox.shrink();
        },
      );






    });
  }



  String _getValidName(String? input) {
    final fallback = '?';
    if (input == null || input.trim().isEmpty) return fallback;

    // Remove invalid characters if necessary
    final clean = input.trim().replaceAll(RegExp(r'[^\w\s]'), '');

    return clean.isEmpty ? fallback : clean;
  }
}
