import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/utils/logger.dart';
import '../../global.dart';
import '../models/vocabulary_user.dart';
import '../repository/vocabulaire_user_repository.dart';


class VocabulaireServerService {
  VocabulaireServerService._privateConstructor();
  final _db = FirebaseFirestore.instance;
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');
  static final VocabulaireServerService _instance = VocabulaireServerService._privateConstructor();
  factory VocabulaireServerService() {
    return _instance;
  }


  Future<Map<String, dynamic>?> fetchSharedListPerso(String guid) async {
   /* try {
      final doc = await _db.collection('listsPerso').doc(guid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      Logger.Red.log('Error fetching shared list: $e');
      return null;
    }*/
  }

  Future<List<dynamic>> getListPersoUser() async {
    Logger.Green.log('getListPersoUser');

    try {
      final HttpsCallable callable = functions.httpsCallable('getListPersoUser');
      final result = await callable.call();

      Logger.Green.log('Successfully called getListPersoUser function : ${result.data}');

      if (result.data is List) {
        final jsonString = jsonEncode(result.data);
        final correctedList = jsonDecode(jsonString) as List;
        return correctedList.map((item) => ListPerso.fromJson(item as Map<String, dynamic>)).toList();
      }

      return [];
    } on FirebaseFunctionsException catch (e) {
      Logger.Red.log('FirebaseFunctionsException in getListPersoUser: ${e.code} - ${e.message}');
      return [];
    } catch (e) {
      Logger.Red.log('An unexpected error occurred in getListPersoUser: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchUserData() async {
    Logger.Blue.log("Attempting to fetch user data...");
    //await VocabulaireUserRepository().importListPersoFromSharePref();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Logger.Red.log("CRITICAL: No user is signed in according to FirebaseAuth. Aborting.");
      return null;
    }

    try {

      final HttpsCallable callable = functions.httpsCallable('getUserData');
      final result = await callable.call();
      Logger.Green.log('Successfully called and executed getUserData function');

      final data = result.data;
      if (data == null) {
        return null;
      }

      // Conversion profonde et sûre en utilisant jsonEncode/Decode
      final jsonString = jsonEncode(data);
     // Logger.Red.log("User data before deserialization: $jsonString");
      final correctedData = jsonDecode(jsonString) as Map<String, dynamic>;

     // Logger.Red.log("correctedData: $correctedData");

      return correctedData;

    } on FirebaseFunctionsException catch (e) {
      Logger.Red.log("FirebaseFunctionsException caught: Code [${e.code}], Message [${e.message}]");
      return null;
    } catch (e) {
      Logger.Red.log('Erreur lors de la récupération des données utilisateur : $e');
      return null;
    }
  }








  Future<void> updateUserData(Map<String, dynamic> userData) async {
    Logger.Yellow.log("updateUserData with Cloud Function");
    Logger.Pink.log("server service updateUserData userData: $userData");

    var lisFinished = await VocabulaireUserRepository().getListFinished(local:'fr');

    Logger.Green.log("getListFinished: $lisFinished");

    if (FirebaseAuth.instance.currentUser == null) {
      Logger.Red.log("User not authenticated, aborting updateUserData call.");
      throw Exception("User must be authenticated to update data.");
    }

    // --- Prépare les champs ---
    userData.remove('listTheme');

    final listLearned = userData['ListGuidVocabularyLearned'];
    final int learnedLen = (listLearned is List) ? listLearned.length : 0;
    final listDefinedEnd = lisFinished;
    final allListView = userData['allListView'];

    // --- Normalise ListPerso venant du modèle Flutter ---
    final listPerso = userData['ListPerso'];
    List<Map<String, dynamic>> listsFromClient = [];
    if (listPerso != null) {
      listsFromClient = (listPerso as List).map<Map<String, dynamic>>((e) {
        if (e is Map<String, dynamic>) return e;
        return (e as dynamic).toJson() as Map<String, dynamic>;
      }).toList();
    }

    final Map<String, dynamic> payload = {
      'ListGuidVocabularyLearned': listLearned,
      'ListPerso': listsFromClient,
      'countGuidVocabularyLearned': learnedLen,
      'ListDefinedEnd': listDefinedEnd,
      'allListView': allListView,
    };

    try {
      // Utilise l'instance globale 'functions'
      final HttpsCallable callable = functions.httpsCallable('updateUserData');
      final result = await callable.call(payload);
      Logger.Green.log('Successfully called updateUserData function: ${result.data}');
    } on FirebaseFunctionsException catch (e) {
      Logger.Red.log('Failed to call updateUserData function: ${e.code} - ${e.message}');
      throw Exception('Failed to update user data via cloud function');
    } catch (e) {
      Logger.Red.log('An unexpected error occurred while calling updateUserData: $e');
      throw Exception('An unexpected error occurred during user data update');
    }
  }
}
