import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/utils/logger.dart';
import '../../global.dart';
import '../models/vocabulary_user.dart';


class VocabulaireServerService {
  //VocabulaireServerService();
  VocabulaireServerService._privateConstructor();
  final _db = FirebaseFirestore.instance;
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference _listPersoCollection = FirebaseFirestore.instance.collection('listperso');
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
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('current_user');
    String? uid;
    if (userJson != null) {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      uid = userMap['uid'] as String?;
    }
    if (uid == null) {
      // log/throw si besoin
      return;
    }

    // --- Prépare les champs "users" ---
    userData.remove('listTheme');

    final listLearned = userData['ListGuidVocabularyLearned'];
    final int learnedLen =
    (listLearned is List) ? listLearned.length : 0;
    final listDefinedEnd = userData['ListDefinedEnd'];
    final allListView = userData['allListView'];

    // --- Normalise ListPerso venant de ton modèle Flutter ---
    final listPerso = userData['ListPerso'];
    List<Map<String, dynamic>> listsFromClient = [];
    if (listPerso != null) {
      // si listPerso est déjà une List<Map> -> garde, sinon appelle toJson()
      listsFromClient = (listPerso as List).map<Map<String, dynamic>>((e) {
        if (e is Map<String, dynamic>) return e;
        // e est probablement un objet ListPerso avec toJson()
        // ignore: avoid_dynamic_calls
        return (e as dynamic).toJson() as Map<String, dynamic>;
      }).toList();
    }

    // 1) Écrit le document user
    await _usersCollection.doc(uid).set({
      'ListGuidVocabularyLearned': listLearned,
      'ListPerso': listsFromClient, // tu peux le garder durant la transition
      'countGuidVocabularyLearned': learnedLen,
      'ListDefinedEnd': listDefinedEnd,
      'allListView': allListView,
    }, SetOptions(merge: true));

    // 2) Synchronise la collection globale `lists`
    await _syncGlobalLists(uid: uid, listsFromClient: listsFromClient);
  }

  /// Upsert toutes les listes actuelles de l'utilisateur dans `lists/`,
  /// supprime celles disparues, et met à jour users/{uid}.listIds.
  Future<void> _syncGlobalLists({
    required String uid,
    required List<Map<String, dynamic>> listsFromClient,
  }) async {
    // Récupère l'état actuel côté "global" pour calculer le diff
    final existingSnap = await _db
        .collection('listsPerso')
        .where('ownerUid', isEqualTo: uid)
        .get();

    final existingIds = existingSnap.docs.map((d) => d.id).toSet();
    final currentIds = listsFromClient
        .map((m) => (m['guid'] ?? m['id'] ?? '').toString().trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    final toDelete = existingIds.difference(currentIds);

    // Batch pour rester atomique (< 500 écritures par batch)
    WriteBatch batch = _db.batch();
    int opCount = 0;
    Future<void> commitIfNeeded() async {
      if (opCount >= 450) { // marge de sécu
        await batch.commit();
        batch = _db.batch();
        opCount = 0;
      }
    }

    // Upsert des listes courantes
    for (final raw in listsFromClient) {
      final guid = (raw['guid'] ?? raw['id'] ?? '').toString().trim();
      if (guid.isEmpty) continue;

      final ref = _db.collection('listsPerso').doc(guid);


      final payload = <String, dynamic>{
        'guid': guid,
        'ownerUid': uid,
        'title': raw['title'] ?? '',
        'isListShare': (raw['isListShare'] ?? raw['isListShare'] ?? false) == true,
        'ownListShare': (raw['ownListShare'] ?? false) == true,
        'urlShare': raw['urlShare'] ?? '',
        'color': raw['color'],
        'listGuidVocabulary': (raw['listGuidVocabulary'] is List)
            ? List<String>.from(raw['listGuidVocabulary'])
            : <String>[],
        'countGuidVocabularyLearned':
        (raw['countGuidVocabularyLearned'] ?? 0) as int,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      batch.set(ref, payload, SetOptions(merge: true));
      opCount++;
      await commitIfNeeded();
    }

    // Suppression des listes obsolètes (celles qui n'existent plus côté client)
    for (final id in toDelete) {
      batch.delete(_db.collection('listsPerso').doc(id));
      opCount++;
      await commitIfNeeded();
    }

    // Met à jour l'index léger côté user
    final userRef = _usersCollection.doc(uid);
    batch.set(userRef, {'listIds': currentIds.toList()}, SetOptions(merge: true));
    opCount++;

    await batch.commit();
  }
}
