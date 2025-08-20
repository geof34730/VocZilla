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

          return Card(
            color: Colors.deepPurple,
            child: ListTile(
              leading: userProfile.imageAvatar.isNotEmpty
                  ? Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.memory(
                  base64Decode(userProfile.imageAvatar),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Assuming 'Avatar' is a valid widget in your project.
                    // The flutter_profile_picture package provides a 'ProfilePicture' widget.
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
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: Center(
                          child: AutoSizeText(
                            // Consider using your localization helper here.
                            // e.g., context.loc.your_position
                            context.loc.your_position,
                            style: getFontForLanguage(
                              codelang:
                              Localizations.localeOf(context).languageCode,
                              fontSize: 20,
                            ).copyWith(
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            minFontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    // The Expanded widget that caused the error has been removed.
                    child: Center(
                      child: AutoSizeText(
                        position.toString(),
                        style: getFontForLanguage(
                          codelang:
                          Localizations.localeOf(context).languageCode,
                          fontSize: 30,
                        ).copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        minFontSize: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
