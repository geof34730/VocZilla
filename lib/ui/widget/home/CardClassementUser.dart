import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:vobzilla/core/utils/localization.dart';
import '../../../core/utils/getFontForLanguage.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_state.dart';

class CardClassementUser extends StatelessWidget {
  final int position;

  const CardClassementUser({
    super.key,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    // The LayoutBuilder was removed as it was not being used.
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          // Use the user profile directly from the BLoC state.
          // This removes the need for the inefficient FutureBuilder.
          final userProfile = state.userProfile;
          final String pseudo = userProfile.pseudo ?? '';

          return SizedBox(
            height: 89,
            // Vous pouvez ajuster cette valeur selon vos besoins.
            child: Card(
                clipBehavior: Clip.antiAlias, // Ceci agira comme un "overflow: hidden"
                color: Colors.deepPurple,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // --- Avatar on the left ---
                      userProfile.imageAvatar.isNotEmpty
                          ? Container(
                              width: 80,
                              height: 80,
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Image.memory(
                                base64Decode(userProfile.imageAvatar),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Avatar(
                                    radius: 40,
                                    name: _getValidName(pseudo),
                                    fontsize: 30,
                                  );
                                },
                              ),
                            )
                          : Avatar(
                              radius: 40,
                              name: _getValidName(pseudo),
                              fontsize: 30,
                            ),
                      const SizedBox(width: 16),
                      // --- Text content on the right ---
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AutoSizeText(
                              context.loc.your_position,
                              style: getFontForLanguage(
                                codelang: Localizations.localeOf(context).languageCode,
                                fontSize: 15,
                              ).copyWith(color: Colors.white),
                              maxLines: 1,
                              minFontSize: 12,
                            ),

                            AutoSizeText(
                              position.toString(),
                              style: getFontForLanguage(
                                codelang: Localizations.localeOf(context).languageCode,
                                fontSize: 30,
                              ).copyWith(color: Colors.white),
                              maxLines: 1,
                              minFontSize: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          );
        }

        // Show a loading indicator if the user is not authenticated yet.
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  String _getValidName(String? input) {
    const fallback = '?';
    if (input == null || input.trim().isEmpty) return fallback;

    // Remove invalid characters if necessary
    final clean = input.trim().replaceAll(RegExp(r'[^\w\s]'), '');

    return clean.isEmpty ? fallback : clean;
  }
}
