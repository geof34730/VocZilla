import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/logger.dart';
import '../../global.dart';
import '../models/vocabulary_user.dart';


class VocabulaireServerService {
  //VocabulaireServerService();
  VocabulaireServerService._privateConstructor();
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');
  static final VocabulaireServerService _instance = VocabulaireServerService._privateConstructor();
  factory VocabulaireServerService() {
    return _instance;
  }

  Future<Map<String, dynamic>?> fetchUserData() async {
    final response = await http.get(Uri.parse(serverVocabulaireUserUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<void> updateUserData(Map<String, dynamic> userData) async {
    Logger.Pink.log("VocabulaireServerService updateUserData $userData");
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('current_user');
    String? uid;
    if (userJson != null) {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      uid = userMap['uid'] as String?;
    }
    userData.remove('ListTheme');

    Logger.Blue.log("VocabulaireServerService updateUserData Clean $userData");
    final list = userData['ListGuidVocabularyLearned'];
    final int ListGuidVocabularyLearnedLength = (list is List) ? list.length : 0;
    Logger.Blue.log("Taille de ListGuidVocabularyLearned : $ListGuidVocabularyLearnedLength");
    final listLearned = userData['ListGuidVocabularyLearned'];

    final listPerso = userData['ListPerso'];
    List<Map<String, dynamic>>? listPersoJson;
    if (listPerso != null) {
      listPersoJson = (listPerso as List)
          .map((e) => (e as ListPerso).toJson())
          .toList();
    }
    if (uid != null && listLearned != null) {
      await _usersCollection
          .doc(uid)
          .set({
            'ListGuidVocabularyLearned': listLearned,
            'ListPerso': listPersoJson,
            'countGuidVocabularyLearned' :ListGuidVocabularyLearnedLength
          },
        SetOptions(merge: true),
      );
/*
      final top3Snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('countGuidVocabularyLearned', descending: true)
          .orderBy('createdAt') // plus ancien d'abord en cas d'égalité
          .limit(3)
          .get();
      final top3 = top3Snapshot.docs.map((doc) => doc.data()).toList();


      Logger.Blue.log("FFFFFFFFF******************");
      Logger.Blue.log(top3);
      Logger.Blue.log("JJJJJJJJJ******************");
*/


    } else {
      Logger.Red.log("Impossible de sauvegarder : uid ou ListGuidVocabularyLearned manquant");
    }


  }
}
