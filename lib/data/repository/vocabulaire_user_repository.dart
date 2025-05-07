import 'package:flutter/material.dart';
import '../models/vocabulary_user.dart';
import '../services/localstorage_service.dart';
import '../services/vocabulaires_server_service.dart';

class VocabulaireUserRepository {
  final LocalStorageService localStorageService;
  final VocabulaireServerService vocabulaireServerService;

  VocabulaireUserRepository({
    required this.localStorageService,
    required this.vocabulaireServerService,
  });




  /// Récupère les données utilisateur depuis le serveur et les stocke localement.
  Future<void> initializeUserData() async {
    try {
      final serverData = await vocabulaireServerService.fetchUserData();
      if (serverData != null) {
        final userData = VocabulaireUser.fromJson(serverData);
        await localStorageService.saveUserData(userData.toJson());
      }
    } catch (e) {
      // Gérer les erreurs de récupération de données
      print('Erreur lors de la récupération des données utilisateur : $e');
    }
  }

  /// Récupère les données utilisateur depuis le stockage local.
  Future<VocabulaireUser?> getUserData() async {
    try {
      final userDataJson = await localStorageService.getUserData();
      if (userDataJson != null) {
        return VocabulaireUser.fromJson(userDataJson);
      }
      return null;
    } catch (e) {
      print(
          'Erreur lors de la récupération des données utilisateur locales : $e');
      return null;
    }
  }

  /// Met à jour les données utilisateur localement et sur le serveur.
  Future<void> updateUserData(VocabulaireUser userData) async {
    try {
      // Mettre à jour le stockage local
      await localStorageService.saveUserData(userData.toJson());

      // Envoyer les données mises à jour au serveur
      await vocabulaireServerService.updateUserData(userData.toJson());
    } catch (e) {
      print('Erreur lors de la mise à jour des données utilisateur : $e');
    }
  }
}


