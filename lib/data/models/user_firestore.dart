// lib/data/models/user_firestore.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vobzilla/data/repository/fcm_repository.dart';

part 'user_firestore.freezed.dart';
part 'user_firestore.g.dart';

@freezed
abstract class UserFirestore with _$UserFirestore {
  const factory UserFirestore({
    required String uid,
    required String email,
    required String displayName,
    required String photoURL,
    required String providerId,
    required bool isEmailVerified,
    required DateTime? createdAt,
    required String fcmToken,

  }) = _UserFirestore;

  factory UserFirestore.fromJson(Map<String, dynamic> json) => _$UserFirestoreFromJson(json);

  static Future<UserFirestore> fromUserCredential(
      UserCredential userCredential) async {
    final user = userCredential.user!;
    String? urlPhoto;

    if (userCredential.credential?.providerId == 'facebook.com' &&
        userCredential.additionalUserInfo?.profile != null &&
        userCredential.additionalUserInfo!.profile!['picture'] is Map &&
        (userCredential.additionalUserInfo!.profile!['picture'] as Map)['data'] is Map && ((userCredential.additionalUserInfo!.profile!['picture'] as Map)['data'] as Map)['url'] != null)
    {
      urlPhoto = userCredential.additionalUserInfo!.profile!['picture']['data']['url'] as String?;
    } else {
      urlPhoto = user.photoURL;
    }

    return UserFirestore(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: urlPhoto ?? '',
      isEmailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      providerId: userCredential.credential?.providerId ?? '',
      fcmToken: await FcmRepository().geToken(),

    );
  }
}


