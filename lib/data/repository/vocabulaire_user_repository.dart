import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/data/repository/vocabulaire_repository.dart';
import '../../core/utils/logger.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
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
    Logger.Pink.log('********VocabulaireUserRepository: initializeUserData');
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


  Future<void> updateListTheme() async {
    try {
      final userDataJson = await localStorageService.getUserData();
      Logger.Blue.log("userData: $userDataJson");
      if (userDataJson != null) {
        final List<ListTheme> userTheme = await VocabulaireService().getThemesData();
        userDataJson['listTheme'] = userTheme;
        await localStorageService.saveUserData(userDataJson);
        final userDataJsonUpdate = await localStorageService.getUserData();
            Logger.Green.log("userData: $userDataJsonUpdate");
      }
    } catch (e) {
      Logger.Red.log('Erreur lors de la récupération des données utilisateur locales : $e');
    }
  }

  Future<VocabulaireUser?> getVocabulaireUserData({required String local}) async {
   Logger.Green.log("getVocabulaireUserData ");
    try {
      var userDataJson = await localStorageService.getUserData();
      Logger.Blue.log("getVocabulaireUserData') userData: $userDataJson");
      if (userDataJson != null) {
        return VocabulaireUser.fromJson(userDataJson);
      }
      else {
        final userData = await getEmptyVocabulaireUserData(local:local);
        return userData;
      }
    } catch (e) {
      Logger.Red.log('Erreur lors de la récupération des données utilisateur locales : $e');
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
      Logger.Red.log('Erreur lors de la mise à jour des données utilisateur : $e');
    }
  }

  Future<VocabulaireUser> getEmptyVocabulaireUserData({required String local}) async {
    Logger.Pink.log('VocabulaireUserRepository:  getEmptyVocabulaireUserData');
    final List<ListTheme> userTheme = await VocabulaireService().getThemesData();
    Logger.Yellow.log("LIST PERSO VIDE");
    VocabulaireUser dataEmpty = VocabulaireUser(
      countVocabulaireAll: await getCountVocabulaireAll(local:local),
      listPerso: [],
      listTheme: userTheme,
      listGuidVocabularyLearned: [],
    );
    await localStorageService.saveUserData(dataEmpty.toJson());
    return dataEmpty;
  }

  Future<void> addVocabulaireUserDataLearned({required String vocabularyGuid,required String local}) async {
    Logger.Red.log("addVocabulaireUserDataLearned: vocabularyGuid: $vocabularyGuid ");
    try {
      Logger.Green.log('Tentative d\'ajout du vocabulaire : $vocabularyGuid');
      final userDataJson = await localStorageService.getUserData();

      print(" addVocabulaireUserDataLearned userDataJson: $userDataJson");

      VocabulaireUser userData;
      if (userDataJson != null) {
        userData = VocabulaireUser.fromJson(userDataJson);
      } else {
        // Initialiser les données utilisateur avec une structure par défaut
        userData = await getEmptyVocabulaireUserData(local:local);
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
    if (vocabulaireSpecificList is ListPerso || vocabulaireSpecificList is ListTheme) {
      return vocabulaireSpecificList.listGuidVocabulary.where((vocabList) => vocabulaireLearned.contains(vocabList)).toList();
    } else
      if (vocabulaireSpecificList is List<dynamic>) {
      return vocabulaireSpecificList.where((vocab) => vocabulaireLearned.contains(vocab['GUID'])).toList();
    } else {
      throw ArgumentError('vocabulaireSpecificList doit être de type ListPerso ou List<dynamic>');
    }
  }

  Future<int>getCountVocabulaireAll({required String local}) async {
    var data = await VocabulaireRepository().getDataTop(local:local);
    return data.length;
  }


  Future<StatisticalLength> getVocabulaireUserDataStatisticalLengthData({String? guidList,int? vocabulaireBegin,int? vocabulaireEnd,ListPerso? listPerso,required bool isListPerso,required bool isListTheme, required String local}) async {
    try {
      var data = [];
      late List<dynamic> dataSlice;
      if(isListPerso){
        dataSlice = await getVocabulaireListPersoByGuidListPerso(guidListPerso: guidList ?? "",local: local);
      }
      else if(isListTheme){
      //////////////////ADD FOR THEME
        Logger.Blue.log("//////////////////ADD FOR THEME sssss");
        dataSlice = await getVocabulaireListThemeByGuidList(guidList: guidList ?? "", local: local);

      }else{
        data = await VocabulaireRepository().getDataTop(local:local); // Ensure this is awaited
        vocabulaireBegin ??= 0;
        vocabulaireEnd ??= data.length;
        dataSlice = data.sublist(vocabulaireBegin, vocabulaireEnd);
      }
      var vocabDataLearned = await getVocabulaireUserDataLearned( vocabulaireSpecificList: dataSlice);
      var vocabLearnedCount = vocabDataLearned.length;
      var countVocabulaireAll = dataSlice.length;
      return StatisticalLength(
          vocabLearnedCount: vocabLearnedCount,
          countVocabulaireAll: countVocabulaireAll
      );
    } catch (e) {
      Logger.Red.log("Erreur lors de la récupération des données: $e");
      rethrow;
    }
  }

  ////BEGIN LIST PERSO
  Future<List<dynamic>> getVocabulaireListPersoByGuidListPerso({required String guidListPerso, required String local}) async {
    VocabulaireUser? userData = await getVocabulaireUserData(local: local);
    if (userData != null) {
      ListPerso? listVocabulairePerso = userData.listPerso.firstWhere(
            (list) => list.guid == guidListPerso,
        orElse: () => ListPerso(guid: "guid", title: "title", color: 52),
      );
      if (listVocabulairePerso != null) {
        List<String> vocabGuids = listVocabulairePerso.listGuidVocabulary;
        List<dynamic> allVocabularies = await VocabulaireRepository().getDataTop(local: local);
        List<dynamic> vocabularies = allVocabularies.where((vocab) {
          return vocabGuids.contains(vocab['GUID']);
        }).toList();
        return vocabularies;
      }
    }
    // Return an empty list if no data is found
    return [];
  }

  Future<List<dynamic>> getVocabulaireListThemeByGuidList({required String guidList, required String local}) async {
    VocabulaireUser? userData = await getVocabulaireUserData(local: local);

    if (userData != null) {
      ListTheme? listVocabulaire = userData.listTheme.firstWhere(
            (list) => list.guid == guidList,
        orElse: () =>
            ListTheme(guid: "guid", title: {"fr": "Default Title"}, listGuidVocabulary: []),
      );

      if (listVocabulaire != null) {
        List<String> vocabGuids = listVocabulaire.listGuidVocabulary;
        List<dynamic> allVocabularies = await VocabulaireRepository().getDataTop(local:local);
        List<dynamic> vocabularies = allVocabularies.where((vocab) {
          return vocabGuids.contains(vocab['GUID']);
        }).toList();

        return vocabularies;
      }
    }

    // Return an empty list if no data is found
    return [];
  }

  Future<void> addListPerso({required ListPerso listPerso, required String local}) async {
    VocabulaireUser? userData = await getVocabulaireUserData(local: local);
    if (userData != null) {
      // Create a new list with the existing items plus the new item
      List<ListPerso> updatedListPerso = List.from(userData.listPerso)..add(listPerso);
      // Use copyWith to create a new VocabulaireUser with the updated list
      VocabulaireUser updatedUserData = userData.copyWith(listPerso: updatedListPerso);
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

  Future<void> updateListPerso({required ListPerso listPerso,required String local}) async {
    try {
      // Récupérer les données utilisateur actuelles
      VocabulaireUser? userData = await getVocabulaireUserData(local: local);
      if (userData != null) {
        // Mettre à jour la liste perso avec les nouvelles valeurs
        List<ListPerso> updatedListPerso = userData.listPerso.map((existingListPerso) {
          if (existingListPerso.guid == listPerso.guid) {
            // Mettre à jour le titre et la couleur
            return existingListPerso.copyWith(
              title: listPerso.title,
              color: listPerso.color,
            );
          }
          return existingListPerso;
        }).toList();
        // Créer un nouvel objet VocabulaireUser avec la liste mise à jour
        VocabulaireUser updatedUserData = userData.copyWith(listPerso: updatedListPerso);
        // Mettre à jour le stockage local
        await updateVocabulaireUserData(userData: updatedUserData);
        Logger.Green.log('Liste perso mise à jour avec succès.');
      } else {
        Logger.Red.log('Erreur: Les données utilisateur sont null.');
      }
    } catch (e) {
      Logger.Red.log('Erreur lors de la mise à jour de la liste perso : $e');
    }
  }

  Future<ListPerso?> getListPerso({required String guidListPerso,required String local}) async {
    try {
      // Récupérer les données utilisateur actuelles
      VocabulaireUser? userData = await getVocabulaireUserData(local:local);

      if (userData != null) {
        // Trouver la liste perso avec le guid spécifié
        ListPerso? listPerso = userData.listPerso.firstWhere(
              (list) => list.guid == guidListPerso,
          orElse: () => ListPerso(guid: "", title: "", color: 54),
        );

        if (listPerso != null) {
          Logger.Green.log('Liste perso trouvée : $listPerso');
          return listPerso;
        } else {
          Logger.Magenta.log('Aucune liste perso trouvée avec le guid : $guidListPerso');
          return null;
        }
      } else {
        Logger.Red.log('Erreur: Les données utilisateur sont null.');
        return null;
      }
    } catch (e) {
      Logger.Red.log('Erreur lors de la récupération de la liste perso : $e');
      return null;
    }
  }

  shareListPerso({required String guid}){
    print(guid);
  }

  Future<void> addVocabulaireListPerso({required String guidListPerso, required String guidVocabulaire, required String local }) async {
    try {
      // Récupérer les données utilisateur actuelles
      VocabulaireUser? userData = await getVocabulaireUserData(local: local);
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

  Future<void> deleteVocabulaireListPerso({required String guidListPerso, required String guidVocabulaire, required String local}) async {
    try {
      // Récupérer les données utilisateur actuelles
      VocabulaireUser? userData = await getVocabulaireUserData(local: local);

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

  Future<StatisticalLength> getVocabulaireListDataStatisticalLengthData({required dynamic list, required bool isListPerso, required bool isListTheme}) async {
    var vocabDataLearned = await getVocabulaireUserDataLearned( vocabulaireSpecificList: list);
    return StatisticalLength(
        vocabLearnedCount: vocabDataLearned.length,
        countVocabulaireAll: list!.listGuidVocabulary.length
    );
  }

  Future<VocabulaireUser?> addCompletedDefinedList({required String listName, required String local}) async {
    Logger.Green.log('Tentative d\'ajout de la liste terminée : $listName');
    try {
      var userData = await getVocabulaireUserData(local: local);
      if (userData != null) {

        if (!userData.ListDefinedEnd.contains(listName)) {
          final updatedUserData = userData.copyWith(
            ListDefinedEnd: List.from(userData.ListDefinedEnd)..add(listName),
          );
          await updateVocabulaireUserData(userData: updatedUserData);
          Logger.Green.log('Liste terminée ajoutée: $listName');
          return updatedUserData;
        } else {
          Logger.Magenta.log('Cette liste terminée existe déjà.');
          return userData; // Retourne les données non modifiées
        }
      } else {
        Logger.Red.log('Erreur: Données utilisateur null, impossible d\'ajouter la liste.');
      }
    } catch (e) {
      Logger.Red.log('Erreur lors de l\'ajout de la liste terminée : $e');
    }
    return null; // Retourne null en cas d'erreur ou si les données sont null
  }

  Future<VocabulaireUser?> removeCompletedDefinedList({required String listName, required String local}) async {
    Logger.Green.log('Tentative de suppression de la liste terminée : $listName');
    try {
      var userData = await getVocabulaireUserData(local: local);
      if (userData != null) {
        if (userData.ListDefinedEnd.contains(listName)) {
          final updatedUserData = userData.copyWith(
            ListDefinedEnd: List.from(userData.ListDefinedEnd)..remove(listName),
          );
          await updateVocabulaireUserData(userData: updatedUserData);
          Logger.Green.log('Liste terminée supprimée: $listName');
          return updatedUserData;
        }
        return userData; // Retourne les données non modifiées si la liste n'a pas été trouvée
      }
    } catch (e) {
      Logger.Red.log('Erreur lors de la suppression de la liste terminée : $e');
    }
    return null; // Retourne null en cas d'erreur ou si les données sont null
  }

  Future<bool> isListEnd({required String listName}) async {
    final userDataJson = await localStorageService.getUserData();
    if(userDataJson?['ListDefinedEnd'] != null){
      return userDataJson?['ListDefinedEnd'].contains(listName);
    }
    else{
      return false;
    }
  }


  late final VocabulaireUserBloc _bloc;

  // Setter method to inject the bloc
  void setBloc(VocabulaireUserBloc bloc) {
    _bloc = bloc;
  }

  Future<void> checkAndUpdateStatutEndList({required String listName, required double percentage, required BuildContext context}) async {
    // print('checkStatutEnDefined listName: $listName');
    bool isInListEnd = await isListEnd(listName: listName);
    final bloc = BlocProvider.of<VocabulaireUserBloc>(context);

    if (percentage == 1.0) {
      ////CHECK PRESENCE LIST END
      if (!isInListEnd) {
        print("add $listName");
        // addCompletedDefinedList(listName: listName,local:"fr");
        bloc.add(AddCompletedDefinedList(listName: listName, local: "fr"));
      }
    } else {
      if (isInListEnd) {
        print("remove $listName");
        // removeCompletedDefinedList(listName: listName,local:"fr");
        bloc.add(RemoveCompletedDefinedList(listName: listName, local: "fr"));
      }
    }
  }
}
