import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/logger.dart';
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

/*
  Future<void> initializeUserData() async {
    Logger.Pink.log('VocabulaireUserRepository: initializeUserData');
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
*/
  /// Récupère les données utilisateur depuis le stockage local.
  Future<VocabulaireUser?> getUserData() async {
    Logger.Pink.log('VocabulaireUserRepository: getUserData');
    try {
      final userDataJson = await localStorageService.getUserData();
      if (userDataJson != null) {
        Logger.Pink.log('VocabulaireUserRepository: getUserData return ${VocabulaireUser.fromJson(userDataJson)}');
        return VocabulaireUser.fromJson(userDataJson);
      }
      Logger.Pink.log('VocabulaireUserRepository: getUserData return null');
      return null;
    } catch (e) {
      Logger.Red.log('Erreur lors de la récupération des données utilisateur locales : $e');
      return null;
    }
  }

  /// Met à jour les données utilisateur localement et sur le serveur.
  Future<void> updateUserData(VocabulaireUser userData) async {
    Logger.Pink.log('VocabulaireUserRepository: updateUserData');
    try {
      // Mettre à jour le stockage local
      await localStorageService.saveUserData(userData.toJson());
      // Envoyer les données mises à jour au serveur
      await vocabulaireServerService.updateUserData(userData.toJson());
    } catch (e) {
      Logger.Red.log('Erreur lors de la mise à jour des données utilisateur : $e');
    }
  }

  Future<void> addVocabularyToLearnedList(String vocabularyGuid) async {
    try {
      Logger.Green.log('Tentative d\'ajout du vocabulaire : $vocabularyGuid');

      // Récupérer les données utilisateur actuelles
      final userDataJson = await localStorageService.getUserData();
      VocabulaireUser userData;

      if (userDataJson != null) {
        userData = VocabulaireUser.fromJson(userDataJson);
      } else {
        // Initialiser les données utilisateur avec une structure par défaut
        userData = VocabulaireUser(
          listPerso: [],
          listTheme: [],
          listGuidVocabularyLearned: [],
        );
        Logger.Green.log('Données utilisateur initialisées par défaut.');
      }

      // Ajouter le vocabulaire à la liste si ce n'est pas déjà présent
      if (!userData.listGuidVocabularyLearned.contains(vocabularyGuid)) {
        userData = userData.copyWith(
          listGuidVocabularyLearned: List.from(userData.listGuidVocabularyLearned)..add(vocabularyGuid),
        );

        // Mettre à jour le stockage local
        await localStorageService.saveUserData(userData.toJson());
        Logger.Green.log('Vocabulaire ajouté au stockage local.');

        // Envoyer les données mises à jour au serveur
        await vocabulaireServerService.updateUserData(userData.toJson());
        Logger.Green.log('Données mises à jour envoyées au serveur.');
      } else {
        Logger.Magenta.log('Le vocabulaire est déjà présent dans la liste.');
      }
    } catch (e) {
      Logger.Red.log('Erreur lors de l\'ajout du vocabulaire à la liste des appris : $e');
    }
  }

  Future<void> removeVocabularyToLearnedList(String vocabularyGuid) async {
    Logger.Red.log('Tentative de suppression du vocabulaire : $vocabularyGuid');
    try {
      // Récupérer les données utilisateur actuelles
      final userDataJson = await localStorageService.getUserData();
      if (userDataJson != null) {
        var userData = VocabulaireUser.fromJson(userDataJson);
        // Supprimer le vocabulaire de la liste s'il est présent
        if (userData.listGuidVocabularyLearned.contains(vocabularyGuid)) {
          userData = userData.copyWith(
            listGuidVocabularyLearned: List.from(userData.listGuidVocabularyLearned)..remove(vocabularyGuid),
          );
          // Mettre à jour le stockage local
          await localStorageService.saveUserData(userData.toJson());
          // Envoyer les données mises à jour au serveur
          await vocabulaireServerService.updateUserData(userData.toJson());
        }
      }
    } catch (e) {
      print('Erreur lors de la suppression du vocabulaire de la liste des appris : $e');
    }
  }


}


