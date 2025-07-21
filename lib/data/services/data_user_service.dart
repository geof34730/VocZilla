// lib/data/services/data_user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_firestore.dart';

class DataUserService {
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  /// Récupère un document utilisateur depuis Firestore par son UID.
  Future<UserFirestore?> getUserFromFirestore(String uid) async {
    final docSnapshot = await _usersCollection.doc(uid).get();
    if (docSnapshot.exists) {
      return UserFirestore.fromJson(docSnapshot.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Sauvegarde ou met à jour un utilisateur dans Firestore.
  Future<void> saveUserToFirestore(UserFirestore user) async {
    await _usersCollection.doc(user.uid).set(user.toJson());
  }

  /// Met à jour des champs spécifiques du profil utilisateur dans Firestore.
  Future<void> updateProfilInFirestore({
    required String uid,
    required String firstName,
    required String lastName,
    required String pseudo,
  }) async {
    await _usersCollection.doc(uid).update({
      'firstName': firstName,
      'lastName': lastName,
      'pseudo': pseudo,
    });
  }
}
