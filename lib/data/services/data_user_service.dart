import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/data/models/vocabulary_user.dart';
import 'package:voczilla/data/services/vocabulaires_server_service.dart';
import 'package:voczilla/data/services/vocabulaires_service.dart';
import '../../core/utils/logger.dart';
import '../../global.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../models/user_firestore.dart';
import '../repository/vocabulaire_user_repository.dart';

class DataUserService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');

  /// Récupère un document utilisateur depuis Firestore par son UID.
  Future<UserFirestore?> getUserFromFirestore({required String uid}) async {
    Logger.Green.log("getUserFromFirestore");
    final docSnapshot = await _usersCollection.doc(uid).get();
    if (docSnapshot.exists) {
      Logger.Cyan.log("DataUserService => getUserFromFirestore fromjson ${docSnapshot.data()}");
      final data = docSnapshot.data() as Map<String, dynamic>;

      // Extraire les GUIDs des listes perso


      // Appeler le service pour obtenir les données complètes des listes perso
      Logger.Green.log("getUserFromFirestore begin service");
      //final List<dynamic> completeListPerso = await VocabulaireServerService().getListPersoUser();

      //Logger.Green.log("completeListPerso $completeListPerso");




    //  Logger.Cyan.log("DataUserService => getUserFromFirestore correctedData $completeListPerso");

     // final List<ListPerso> listPerso = completeListPerso.map((item) =>ListPerso.fromJson(item as Map<String, dynamic>)).toList();
     // final vocabulaireUser = VocabulaireUser(listPerso: listPerso, countVocabulaireAll: globalCountVocabulaireAll);
     // final List<ListTheme> userTheme = await VocabulaireService().getThemesData();
     // final updatedVocabulaireUser = vocabulaireUser.copyWith(listTheme: userTheme);

     // Logger.Green.log("updatedVocabulaireUser: $updatedVocabulaireUser");


     // await VocabulaireUserRepository().updateVocabulaireUserData(userData: updatedVocabulaireUser);

     Logger.Green.log("getUserFromFirestore before remove listeperso: $data");
      data.remove("ListPerso");
      Logger.Green.log("getUserFromFirestore after remove listeperso: $data");
      return UserFirestore.fromJson(data); // Note: This still uses the original data for UserFirestore


    }
    Logger.Green.log("getUserFromFirestore END");
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
      'pseudo': pseudo,
    };
    if (imageAvatar != null) {
      data['imageAvatar'] = imageAvatar;
    }
    await _usersCollection.doc(uid).update(data);
  }
}
