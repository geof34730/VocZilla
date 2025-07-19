import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/logger.dart';
import '../models/user_firestore.dart';

class DataUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Saves a new user to Firestore and returns the saved user object.
  Future<UserFirestore> saveUserToFirestore({required UserFirestore user}) async {
    Logger.Red.log("saveUserToFirestore: ${user.toJson()}");
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toJson());
      // Return the user object on success
      return user;
    } catch (e) {
      // It's good practice to also log the error and rethrow
      Logger.Red.log("Error in saveUserToFirestore: $e");
      throw Exception("Erreur lors de la sauvegarde de l'utilisateur : $e");
    }
  }

  /// Updates an existing user in Firestore and returns the updated user object.
  Future<UserFirestore> updateUserToFirestore({required UserFirestore user}) async {
    Logger.Red.log("updateUserToFirestore: ${user.toJson()}");
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toJson());
      // Return the user object on success
      return user;
    } catch (e) {
      Logger.Red.log("Error in updateUserToFirestore: $e");
      throw Exception("Erreur lors de la mise à jour de l'utilisateur : $e");
    }
  }

  Future<bool> checkUserFirestoreExists(String uid) async {
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
