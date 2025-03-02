import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_firestore.dart';
import '../services/data_user_service.dart';

class DataUserRepository {
  final DataUserService _dataUserService = DataUserService();
  UserFirestore? _userFirestore;

  Future<void> createUser({required UserCredential? userCredential}) async {
    if(userCredential == null) return;

    final String uid = userCredential.user!.uid;
    // Vérifier si l'utilisateur existe déjà
    bool userExists = await _dataUserService.checkUserExists(uid);
    if (!userExists) {
      // Convertir en modèle UserFirestore
      UserFirestore userFirestore = UserFirestore.fromUserCredential(userCredential);
      // Enregistrer l'utilisateur dans Firestore
      await _dataUserService.saveUserToFirestore(userFirestore);
    }
  }

  String getPhotoURL() {
    return _userFirestore?.photoURL ?? '';
  }

  Future<UserFirestore?> getUser(String uid) async {
    return await _dataUserService.getUserFromFirestore(uid);
  }
}
DataUserRepository dataUserRepository = DataUserRepository();
