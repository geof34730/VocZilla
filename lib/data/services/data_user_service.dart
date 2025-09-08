import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/data/models/vocabulary_user.dart';
import 'package:voczilla/data/services/vocabulaires_service.dart';
import '../../core/utils/logger.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../models/user_firestore.dart';
import '../repository/vocabulaire_user_repository.dart';

class DataUserService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');
  /// Récupère un document utilisateur depuis Firestore par son UID.
  Future<UserFirestore?> getUserFromFirestore({required String uid}) async {
    final docSnapshot = await _usersCollection.doc(uid).get();
    if (docSnapshot.exists) {
      Logger.Cyan.log("DataUserService => getUserFromFirestore fromjson ${docSnapshot.data()}");
      final data = docSnapshot.data() as Map<String, dynamic>;
      final vocabulaireUser = VocabulaireUser.fromJson(data);
      final List<ListTheme> userTheme = await VocabulaireService().getThemesData();
      final updatedVocabulaireUser = vocabulaireUser.copyWith(listTheme: userTheme);
      VocabulaireUserRepository().updateVocabulaireUserData(userData: updatedVocabulaireUser);
      final List<ListPerso> listPerso = updatedVocabulaireUser.listPerso; // récupère la liste
     //   context.read<VocabulaireUserBloc>().add(VocabulaireUserRefresh(local: "fr"));


      return UserFirestore.fromJson(data);
    }
    return null;
  }

  /// Sauvegarde ou met à jour un utilisateur dans Firestore.
  Future<void> saveUserToFirestore({required UserFirestore user}) async {

   Logger.Cyan.log("DataUserService => saveUserToFirestore $user");
    await _usersCollection.doc(user.uid).set(user.toJson(), SetOptions(merge: true));
  }

  /// Met à jour des champs spécifiques du profil utilisateur dans Firestore.
  Future<void> updateProfilInFirestore({
    required String uid,
    required String pseudo,
    String? imageAvatar,
  }) async {
    final Map<String, dynamic> data = {
      'pseudo': pseudo ,
    };
    if (imageAvatar != null) {
      data['imageAvatar'] = imageAvatar;
    }
    await _usersCollection.doc(uid).update(data);
  }



}
