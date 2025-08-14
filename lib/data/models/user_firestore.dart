// lib/data/models/user_firestore.dart

import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import '../repository/fcm_repository.dart';

part 'user_firestore.freezed.dart';
part 'user_firestore.g.dart';

@freezed
abstract class UserFirestore with _$UserFirestore {
  const factory UserFirestore({
    required String uid,
    @Default('Guest') String pseudo,
    @Default('') String photoURL,
    @Default('') String imageAvatar,
    @Default([]) List<String> fcmTokens,
    DateTime? createdAt,


  }) = _UserFirestore;

  factory UserFirestore.fromJson(Map<String, dynamic> json) =>
      _$UserFirestoreFromJson(json);

  static Future<UserFirestore> fromUserCredential(UserCredential userCredential) async {
    final user = userCredential.user!;
    String? urlPhoto;

    // Logique pour obtenir la bonne URL de photo, en particulier pour Facebook
    if (userCredential.credential?.providerId == 'facebook.com' &&
        userCredential.additionalUserInfo?.profile != null &&
        userCredential.additionalUserInfo!.profile!['picture'] is Map &&
        (userCredential.additionalUserInfo!.profile!['picture'] as Map)['data']
        is Map &&
        ((userCredential.additionalUserInfo!.profile!['picture'] as Map)['data']
        as Map)['url'] !=
            null) {
      urlPhoto = userCredential.additionalUserInfo!.profile!['picture']['data']
      ['url'] as String?;
    } else {
      urlPhoto = user.photoURL;
    }

    final finalPhotoUrl = urlPhoto ?? '';
    String imageAvatarBase64 = '';

    // Si une URL de photo existe, la télécharger et la convertir en Base64
    if (finalPhotoUrl.isNotEmpty) {
      try {
        // MODIFICATION : On ajoute un timeout de 10 secondes à la requête.
        final response = await http.get(Uri.parse(finalPhotoUrl)).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          imageAvatarBase64 = base64Encode(response.bodyBytes);
        } else {
          print('Failed to load avatar image: ${response.statusCode}');
        }
      } on TimeoutException {
        // Gère spécifiquement le cas où la requête dépasse le temps imparti.
        print('Error fetching avatar image: The request timed out.');
      } catch (e) {
        print('Error fetching avatar image: $e');
      }
    }


    // Les champs lastName, firstName, et pseudo sont initialisés comme des chaînes vides.
    // L'utilisateur sera invité à les remplir plus tard.
    return UserFirestore(
      uid: user.uid,
      pseudo: 'Guest', // Initialisé comme vide
      imageAvatar: imageAvatarBase64,
      photoURL: finalPhotoUrl,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      fcmTokens: await FcmRepository().getListFcmToken(),
    );
  }



}


