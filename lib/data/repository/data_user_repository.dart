import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_firestore.dart';
import '../services/data_user_service.dart';

class DataUserRepository {
  final DataUserService _dataUserService = DataUserService();
  UserFirestore? _userFirestore;

  Future<void> createUser({required UserCredential? userCredential}) async {
    if(userCredential == null) return;
    final String uid = userCredential.user!.uid;
    bool userExists = await _dataUserService.checkUserExists(uid);
    UserFirestore userFirestore = UserFirestore.fromUserCredential(userCredential);
    if (!userExists) {
      await _dataUserService.saveUserToFirestore(userFirestore);
    }
 }

  Future<void> updateDisplayName({required String displayName,required dynamic uid}) async {
    _userFirestore = await getUser(uid);
    _userFirestore = _userFirestore?.copyWith(displayName: displayName);
    await _dataUserService.updateUserToFirestore(_userFirestore!);
  }

  String getPhotoURL() {
    return _userFirestore?.photoURL ?? '';
  }

  Future<UserFirestore?> getUser(String uid) async {
    return await _dataUserService.getUserFromFirestore(uid);
  }

  Future<void> synchroDisplayNameWithFirestore(User user) async {
    _userFirestore = await getUser(user.uid);
    if (_userFirestore != null) {
      if (_userFirestore!.displayName.isEmpty ||
          _userFirestore!.displayName == "" ||
          _userFirestore!.displayName != user.displayName) {
        try {
          if(user.displayName != null) {
            await updateDisplayName(displayName: user.displayName as String, uid: user.uid);
          }
          //print("DisplayName mis à jour avec succès.");
        } catch (e) {
          //print("Erreur lors de la mise à jour du DisplayName: $e");
        }
      }
    }
  }

}
DataUserRepository dataUserRepository = DataUserRepository();
