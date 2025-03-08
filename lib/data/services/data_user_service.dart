import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_firestore.dart';

class DataUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserToFirestore(UserFirestore user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }

  Future<void> updateUserToFirestore(UserFirestore user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toJson());
  }

  Future<bool> checkUserExists(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      throw Exception("Erreur lors de la vérification de l'utilisateur : $e");
    }
  }

  Future<UserFirestore?> getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserFirestore.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception("Erreur lors de la récupération de l'utilisateur : $e");
    }
  }
}

