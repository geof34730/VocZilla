import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/logger.dart';
import '../models/user_firestore.dart';

class DataUserService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');

  /// Récupère un document utilisateur depuis Firestore par son UID.
  Future<UserFirestore?> getUserFromFirestore(String uid) async {
    final docSnapshot = await _usersCollection.doc(uid).get();
    if (docSnapshot.exists) {
      Logger.Green.log("getUserFromFirestore $uid ${docSnapshot.data()}");

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
    String? imageAvatar,
  }) async {
    final Map<String, dynamic> data = {
      'firstName': firstName,
      'lastName': lastName,
      'pseudo': pseudo,
    };
    if (imageAvatar != null) {
      data['imageAvatar'] = imageAvatar;
    }
    await _usersCollection.doc(uid).update(data);
  }
}
