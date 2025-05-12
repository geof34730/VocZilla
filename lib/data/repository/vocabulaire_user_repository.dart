import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/repository/vocabulaires_repository.dart';
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
  final BuildContext context;

  VocabulaireUserRepository({
    required this.context,
  });

  Future<void> initializeUserData() async {
    Logger.Pink.log('VocabulaireUserRepository: initializeUserData');
    try {
      final serverData = await vocabulaireServerService.fetchUserData();
      if (serverData != null) {
        final userData = VocabulaireUser.fromJson(serverData);
        await localStorageService.saveUserDataLearned(userData.toJson());
      }
    } catch (e) {
      // Gérer les erreurs de récupération de données
      print('Erreur lors de la récupération des données utilisateur : $e');
    }
  }

  Future<VocabulaireUser?> getUserData() async {
    Logger.Pink.log('VocabulaireUserRepository: getUserData');
    try {
      final userDataJson = await localStorageService.getUserDataLearned();
      if (userDataJson != null) {
        Logger.Pink.log(
            'VocabulaireUserRepository: getUserData return ${VocabulaireUser.fromJson(userDataJson)}');
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

  Future<void> updateVocabulaireUserDataLearned({required VocabulaireUser userData}) async {
    Logger.Pink.log('VocabulaireUserRepository: updateUserData');
    try {
      // Mettre à jour le stockage local
      await localStorageService.saveUserDataLearned(userData.toJson());
      // Envoyer les données mises à jour au serveur
      await vocabulaireServerService.updateUserData(userData.toJson());
    } catch (e) {
      Logger.Red.log(
          'Erreur lors de la mise à jour des données utilisateur : $e');
    }
  }

  Future<void> addVocabulaireUserDataLearned({required String vocabularyGuid}) async {
    Logger.Red.log("addVocabulaireUserDataLearned: vocabularyGuid: $vocabularyGuid ");
    try {
      Logger.Green.log('Tentative d\'ajout du vocabulaire : $vocabularyGuid');
      final userDataJson = await localStorageService.getUserDataLearned();
      VocabulaireUser userData;
      if (userDataJson != null) {
        userData = VocabulaireUser.fromJson(userDataJson);
      } else {
        // Initialiser les données utilisateur avec une structure par défaut
        final vocabulairesAll = await VocabulaireService().getAllData();
        userData = VocabulaireUser(
          countVocabulaireAll: vocabulairesAll.length,
          listPerso: [],
          listTheme: [],
          listGuidVocabularyLearned: [],
        );
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
        await localStorageService.saveUserDataLearned(userData.toJson());
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
      final userDataJson = await localStorageService.getUserDataLearned();
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
          await localStorageService.saveUserDataLearned(userData.toJson());
          // Envoyer les données mises à jour au serveur
          await vocabulaireServerService.updateUserData(userData.toJson());
        }
      }
    } catch (e) {
      Logger.Red.log('Erreur lors de la suppression du vocabulaire de la liste des appris : $e');
    }
  }

  Future<List<dynamic>> getDataNotLearned({required List<dynamic> vocabulaireSpecificList}) async {
    final userDataJson = await localStorageService.getUserDataLearned();
    final vocabulaireLearned = userDataJson != null
        ? VocabulaireUser.fromJson(userDataJson).listGuidVocabularyLearned
        : <String>[];
    return vocabulaireSpecificList
        .where((vocab) => !vocabulaireLearned.contains(vocab['GUID']))
        .toList();
  }

  Future<List> getDataLearned({required List<dynamic> vocabulaireSpecificList}) async {
    final userDataJson = await localStorageService.getUserDataLearned();
    final vocabulaireLearned = userDataJson != null
        ? VocabulaireUser
        .fromJson(userDataJson)
        .listGuidVocabularyLearned
        : <String>[];
    return vocabulaireSpecificList
        .where((vocab) => vocabulaireLearned.contains(vocab['GUID']))
        .toList();
  }

  Future<StatisticalLength> getVocabulairesStatisticalLengthData({ int? vocabulaireBegin,  int? vocabulaireEnd, List<dynamic>? userDataSpecificList}) async {
    var data =[];
    if(userDataSpecificList != null){
       data=userDataSpecificList;
    }
    else {
       data = await VocabulairesRepository(context: context).getDataTop(); // Ensure this is awaited
    }
    vocabulaireBegin ??= 0;
    vocabulaireEnd ??= data.length;
    final List<dynamic> dataSlice = data.sublist(vocabulaireBegin, vocabulaireEnd);
    var vocabDataLearned = await getDataLearned( vocabulaireSpecificList: dataSlice);
    var vocabLearnedCount = vocabDataLearned.length;
    var countVocabulaireAll = dataSlice.length;
    return StatisticalLength(
        vocabLearnedCount: vocabLearnedCount,
        countVocabulaireAll: countVocabulaireAll
    );
  }

}


