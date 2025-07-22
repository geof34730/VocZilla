// lib/data/repository/data_user_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vobzilla/data/models/user_firestore.dart';
import 'package:vobzilla/data/services/data_user_service.dart';
import 'package:vobzilla/data/services/localstorage_service.dart';

class DataUserRepository {
  final DataUserService _dataUserService = DataUserService();
  final LocalStorageService _localStorageService = LocalStorageService();
  /// Récupère les informations de l'utilisateur.
  /// Tente d'abord de charger depuis le cache local, sinon depuis Firestore.
  Future<UserFirestore?> getUser(String uid) async {
    // 1. Essayer de charger depuis le stockage local (cache rapide)
    UserFirestore? user = await _localStorageService.loadUser();
    if (user != null && user.uid == uid) {
      return user;
    }
    // 2. Si non trouvé dans le cache, récupérer depuis Firestore
    user = await _dataUserService.getUserFromFirestore(uid);
    // 3. Si trouvé sur Firestore, le sauvegarder dans le cache local pour les prochains accès
    if (user != null) {
      await _localStorageService.saveUser(user);
    }

    return user;
  }

  /// Sauvegarde un nouvel utilisateur sur Firestore et dans le cache local.
  Future<void> saveUser(UserFirestore user) async {
    await _dataUserService.saveUserToFirestore(user);
    await _localStorageService.saveUser(user);
  }

  /// Met à jour le profil de l'utilisateur sur Firestore et rafraîchit le cache local.
  Future<void> updateProfilUserFirestore({
    required String firstName,
    required String lastName,
    required String pseudo,
    String? imageAvatar,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("Utilisateur non authentifié pour la mise à jour du profil.");
    }

    // Met à jour dans Firestore
    await _dataUserService.updateProfilInFirestore(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      pseudo: pseudo,
      imageAvatar: imageAvatar,
    );

    // Invalide le cache local en le supprimant.
    // La prochaine fois que `getUser` sera appelé, il rechargera les données fraîches.
     await _localStorageService.clearUser();
  }
}
