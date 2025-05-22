import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/repository/vocabulaire_repository.dart';
import 'package:vobzilla/logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../core/utils/logger.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../models/statistical_length.dart';
import '../models/vocabulary_user.dart';
import '../services/localstorage_service.dart';
import '../services/vocabulaires_server_service.dart';
import '../services/vocabulaires_service.dart';

class VocabulaireUserRepository {
  final LocalStorageService localStorageService = LocalStorageService();
  final VocabulaireServerService vocabulaireServerService = VocabulaireServerService();


  VocabulaireUserRepository();

  Future<void> initializeVocabulaireUserData() async {
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

  Future<VocabulaireUser?> getVocabulaireUserData() async {
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
      Logger.Red.log(
          'Erreur lors de la récupération des données utilisateur locales : $e');
      return null;
    }
  }

  Future<void> updateVocabulaireUserData({required VocabulaireUser userData}) async {
    Logger.Pink.log('VocabulaireUserRepository: updateUserData');
    try {
      // Mettre à jour le stockage local
      await localStorageService.saveUserData(userData.toJson());
      // Envoyer les données mises à jour au serveur
      await vocabulaireServerService.updateUserData(userData.toJson());
    } catch (e) {
      Logger.Red.log(
          'Erreur lors de la mise à jour des données utilisateur : $e');
    }
  }

  Future<VocabulaireUser> getEmptyVocabulaireUserData() async {
    final vocabulairesAll = await VocabulaireService().getAllData();
    return VocabulaireUser(
      countVocabulaireAll: vocabulairesAll.length,
      listPerso: [],
      listTheme: [],
      listGuidVocabularyLearned: [],
    );
  }

  Future<void> addVocabulaireUserDataLearned({required String vocabularyGuid}) async {
    Logger.Red.log("addVocabulaireUserDataLearned: vocabularyGuid: $vocabularyGuid ");
    try {
      Logger.Green.log('Tentative d\'ajout du vocabulaire : $vocabularyGuid');
      final userDataJson = await localStorageService.getUserData();
      VocabulaireUser userData;
      if (userDataJson != null) {
        userData = VocabulaireUser.fromJson(userDataJson);
      } else {
        // Initialiser les données utilisateur avec une structure par défaut
        userData = await getEmptyVocabulaireUserData();
        Logger.Green.log('Données utilisateur initialisées par défaut.');
      }
      // Ajouter le vocabulaire à la liste si ce n'est pas déjà présent

      Logger.Red.log("vocabularyGuid : $vocabularyGuid");
      Logger.Red.log("userData.listGuidVocabularyLearned : ${userData.listGuidVocabularyLearned}");

      if (!userData.listGuidVocabularyLearned.contains(vocabularyGuid)) {
        userData = userData.copyWith(
          listGuidVocabularyLearned: List.from(
              userData.listGuidVocabularyLearned)
            ..add(vocabularyGuid),
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
      Logger.Red.log(
          'Erreur lors de l\'ajout du vocabulaire à la liste des appris : $e');
    }
  }

  Future<void> removeVocabulaireUserDataLearned({required String vocabularyGuid}) async {
    Logger.Red.log('Tentative de suppression du vocabulaire : $vocabularyGuid');
    try {
      // Récupérer les données utilisateur actuelles
      final userDataJson = await localStorageService.getUserData();
      if (userDataJson != null) {
        var userData = VocabulaireUser.fromJson(userDataJson);
        // Supprimer le vocabulaire de la liste s'il est présent
        if (userData.listGuidVocabularyLearned.contains(vocabularyGuid)) {
          userData = userData.copyWith(
            listGuidVocabularyLearned: List.from(
                userData.listGuidVocabularyLearned)
              ..remove(vocabularyGuid),
          );
          // Mettre à jour le stockage local
          await localStorageService.saveUserData(userData.toJson());
          // Envoyer les données mises à jour au serveur
          await vocabulaireServerService.updateUserData(userData.toJson());
        }
      }
    } catch (e) {
      Logger.Red.log('Erreur lors de la suppression du vocabulaire de la liste des appris : $e');
    }
  }

  Future<List<dynamic>> getVocabulaireUserDataNotLearned({required dynamic vocabulaireSpecificList}) async {

    final userDataJson = await localStorageService.getUserData();
    final vocabulaireLearned = userDataJson != null
        ? VocabulaireUser
        .fromJson(userDataJson)
        .listGuidVocabularyLearned
        : <String>[];
    Logger.Red.log("userDataJson: $userDataJson");
    Logger.Red.log("vocabulaireLearned: $vocabulaireLearned");
    if (vocabulaireSpecificList is ListPerso) {
      return vocabulaireSpecificList.listGuidVocabulary.where((vocabListPerso) => !vocabulaireLearned.contains(vocabListPerso)).toList();
    } else if (vocabulaireSpecificList is List<dynamic>) {
      return vocabulaireSpecificList.where((vocab) => !vocabulaireLearned.contains(vocab['GUID'])).toList();
    } else {
      throw ArgumentError('vocabulaireSpecificList doit être de type ListPerso ou List<dynamic>');
    }
  }



  Future<List> getVocabulaireUserDataLearned({required dynamic  vocabulaireSpecificList}) async {
    final userDataJson = await localStorageService.getUserData();
    final vocabulaireLearned = userDataJson != null
        ? VocabulaireUser
        .fromJson(userDataJson)
        .listGuidVocabularyLearned
        : <String>[];
    if (vocabulaireSpecificList is ListPerso) {
        return vocabulaireSpecificList.listGuidVocabulary.where((vocabListPerso) => vocabulaireLearned.contains(vocabListPerso)).toList();
    } else if (vocabulaireSpecificList is List<dynamic>) {
        return vocabulaireSpecificList.where((vocab) => vocabulaireLearned.contains(vocab['GUID'])).toList();
    } else {
      throw ArgumentError('vocabulaireSpecificList doit être de type ListPerso ou List<dynamic>');
    }
  }

  Future<StatisticalLength> getVocabulaireUserDataStatisticalLengthData({ int? vocabulaireBegin,  int? vocabulaireEnd}) async {
    var data =[];
    data = await VocabulaireRepository().getDataTop(); // Ensure this is awaited
    vocabulaireBegin ??= 0;
    vocabulaireEnd ??= data.length;
    final List<dynamic> dataSlice = data.sublist(vocabulaireBegin, vocabulaireEnd);
    var vocabDataLearned = await getVocabulaireUserDataLearned( vocabulaireSpecificList: dataSlice);
    var vocabLearnedCount = vocabDataLearned.length;
    var countVocabulaireAll = dataSlice.length;
    return StatisticalLength(
        vocabLearnedCount: vocabLearnedCount,
        countVocabulaireAll: countVocabulaireAll
    );
  }

  ////BEGIN LIST PERSO
  Future<void> addListPerso({required ListPerso listPerso}) async {
    VocabulaireUser? userData = await getVocabulaireUserData();
    if (userData != null) {
      // Create a new list with the existing items plus the new item
      List<ListPerso> updatedListPerso = List.from(userData.listPerso)..add(listPerso);

      // Use copyWith to create a new VocabulaireUser with the updated list
      VocabulaireUser updatedUserData = userData.copyWith(
          listPerso: updatedListPerso);

      // Update the user data
      await updateVocabulaireUserData(userData: updatedUserData);
    }
  }

  Future<void> deleteListPerso({required String guid}) async {
    Logger.Red.log("Tentative de suppression de la liste perso : $guid");
    try {
      // Récupérer les données utilisateur actuelles
      final userDataJson = await localStorageService.getUserData();
      if (userDataJson != null) {
        var userData = VocabulaireUser.fromJson(userDataJson);
        // Supprimer la liste perso de la liste s'il est présent
        if (userData.listPerso.any((listPerso) => listPerso.guid == guid)) {
          userData = userData.copyWith(
            listPerso: userData.listPerso.where((listPerso) => listPerso.guid != guid).toList(),
          );
          // Mettre à jour le stockage local
          await localStorageService.saveUserData(userData.toJson());
          Logger.Green.log('Liste perso supprimée du stockage local.');
          // Envoyer les données mises à jour au serveur
          await vocabulaireServerService.updateUserData(userData.toJson());
          Logger.Green.log('Données mises à jour envoyées au serveur.');
        } else {
          Logger.Magenta.log('La liste perso n\'est pas présente dans la liste.');
        }
      }
    } catch (e) {
      Logger.Red.log('Erreur lors de la suppression de la liste perso : $e');
    }
  }

  editListPerso({required String guid}){
    print(guid);
  }

  shareListPerso({required String guid}){
    print(guid);
  }

  Future<void> addVocabulaireListPerso({required String guidListPerso, required String guidVocabulaire }) async {
    try {
      // Récupérer les données utilisateur actuelles
      VocabulaireUser? userData = await getVocabulaireUserData();
      if (userData != null) {
        // Trouver la liste perso avec le guid spécifié
        List<ListPerso> updatedListPerso = userData.listPerso.map((listPerso) {
          if (listPerso.guid == guidListPerso) {
            // Ajouter le guidVocabulaire à la liste des vocabulaires de cette liste perso
            List<String> updatedVocabulaireList = List.from(listPerso.listGuidVocabulary)..add(guidVocabulaire);
            return listPerso.copyWith(listGuidVocabulary: updatedVocabulaireList);
          }
          return listPerso;
        }).toList();
        // Mettre à jour les données utilisateur avec la liste perso modifiée
        VocabulaireUser updatedUserData = userData.copyWith(listPerso: updatedListPerso);
        // Mettre à jour le stockage local
        await updateVocabulaireUserData(userData: updatedUserData);
        Logger.Green.log(updatedUserData);
        Logger.Green.log('Vocabulaire ajouté à la liste perso.');
      } else {
        Logger.Red.log('Erreur: Les données utilisateur sont null.');
      }
    } catch (e) {
      Logger.Red.log('Erreur lors de l\'ajout du vocabulaire à la liste perso : $e');
    }
  }

  Future<void> deleteVocabulaireListPerso({required String guidListPerso, required String guidVocabulaire}) async {
    try {
      // Récupérer les données utilisateur actuelles
      VocabulaireUser? userData = await getVocabulaireUserData();

      if (userData != null) {
        // Trouver la liste perso avec le guid spécifié
        List<ListPerso> updatedListPerso = userData.listPerso.map((listPerso) {
          if (listPerso.guid == guidListPerso) {
            // Supprimer le guidVocabulaire de la liste des vocabulaires de cette liste perso
            List<String> updatedVocabulaireList = List.from(listPerso.listGuidVocabulary)..remove(guidVocabulaire);
            return listPerso.copyWith(listGuidVocabulary: updatedVocabulaireList);
          }
          return listPerso;
        }).toList();

        // Mettre à jour les données utilisateur avec la liste perso modifiée
        VocabulaireUser updatedUserData = userData.copyWith(listPerso: updatedListPerso);

        // Mettre à jour le stockage local
        await updateVocabulaireUserData(userData: updatedUserData);
        Logger.Green.log('Vocabulaire supprimé de la liste perso.');
      } else {
        Logger.Red.log('Erreur: Les données utilisateur sont null.');
      }
    } catch (e) {
      Logger.Red.log('Erreur lors de la suppression du vocabulaire de la liste perso : $e');
    }
  }

  Future<StatisticalLength> getVocabulaireListPersoDataStatisticalLengthData({required ListPerso? listPerso}) async {
    var vocabDataLearned = await getVocabulaireUserDataLearned( vocabulaireSpecificList: listPerso);
    return StatisticalLength(
        vocabLearnedCount: vocabDataLearned.length,
        countVocabulaireAll: listPerso!.listGuidVocabulary.length
    );
  }
}


