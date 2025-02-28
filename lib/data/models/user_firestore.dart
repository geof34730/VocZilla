// lib/data/models/user_firestore.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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
  }) = _UserFirestore;

  factory UserFirestore.fromJson(Map<String, dynamic> json) => _$UserFirestoreFromJson(json);

  factory UserFirestore.fromUserCredential(UserCredential userCredential) {
    final user = userCredential.user!;
    return UserFirestore(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL ?? '',
      isEmailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      providerId: userCredential.credential?.providerId ?? '',
    );
  }
}



