// lib/data/repository/data_user_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:voczilla/data/models/user_firestore.dart';
import 'package:voczilla/data/services/data_user_service.dart';
import 'package:voczilla/data/services/localstorage_service.dart';

import '../../core/utils/logger.dart';

class DataUserRepository {
  final DataUserService _dataUserService = DataUserService();
  final LocalStorageService _localStorageService = LocalStorageService();
  /// Récupère les informations de l'utilisateur.
  /// Tente d'abord de charger depuis le cache local, sinon depuis Firestore.
  Future<UserFirestore?> getUser({required String uid}) async {
    // 1. Essayer de charger depuis le stockage local (cache rapide)
    UserFirestore? user = await _localStorageService.loadUser();

    Logger.Yellow.log('**** DataUserRepository  => getUser 1 => ${user.toString()}');

    if (user != null && user.uid == uid) {
      return user;
    }
    Logger.Yellow.log('**** DataUserRepository  => getUser 2 => ${user.toString()}');
    // 2. Si non trouvé dans le cache, récupérer depuis Firestore
    user = await _dataUserService.getUserFromFirestore(uid: uid);
    // 3. Si trouvé sur Firestore, le sauvegarder dans le cache local pour les prochains accès




    Logger.Yellow.log('**** DataUserRepository  => getUser 3 => ${user.toString()}');
    if (user != null) {
      await _localStorageService.saveUser(user);
    }

    Logger.Yellow.log('**** DataUserRepository  => getUser 4 => ${user.toString()}');
    return user;
  }

  /// Sauvegarde un nouvel utilisateur sur Firestore et dans le cache local.
  Future<void> saveUser({required UserFirestore user,required bool mergeData}) async {
    Logger.Yellow.log('DataUserRepository => saveUser => ${user}');
    await _dataUserService.saveUserToFirestore(user:user);
    await _localStorageService.saveUser(user);
  }

  /// Met à jour le profil de l'utilisateur sur Firestore et rafraîchit le cache local.
  Future<void> updateProfilUserFirestore({
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
      pseudo: pseudo,
      imageAvatar:imageAvatar
    );
     await _localStorageService.clearUser();
  }
}
