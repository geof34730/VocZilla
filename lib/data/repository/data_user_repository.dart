import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_firestore.dart';
import '../services/data_user_service.dart';
import 'fcm_repository.dart';

class DataUserRepository {
  final DataUserService _dataUserService = DataUserService();
  UserFirestore? _userFirestore;

  Future<void> createUser({required UserCredential? userCredential}) async {
    if (userCredential == null) return;
    final String uid = userCredential.user!.uid;
    bool userExists = await _dataUserService.checkUserExists(uid);
    UserFirestore userFirestore = await UserFirestore.fromUserCredential(userCredential);
    if (!userExists) {
      await _dataUserService.saveUserToFirestore(userFirestore);
    } else {
      _userFirestore = await getUser(uid);
      if (_userFirestore != null) {
        String newToken = await FcmRepository().geToken();

        // Check if the token is already in the list
        bool tokenExists = _userFirestore!.fcmTokens.contains(newToken);
        print("*****_userFirestore!.fcmTokens.lenght ${_userFirestore!.fcmTokens.length}");
        if (!tokenExists) {
          // Add the new token to the list
          List<String> updatedTokens = List<String>.from(_userFirestore!.fcmTokens);
          updatedTokens.add(newToken);

          // Update the user with the new list of tokens
          _userFirestore = _userFirestore!.copyWith(fcmTokens: updatedTokens);
          await _dataUserService.updateUserToFirestore(_userFirestore!);
        }
        else{
          print("Token already exists");
        }
      }
    }
  }





  Future<void> updateDisplayName({required String displayName,required dynamic uid}) async {
    print("updateDisplayName REPOSITITORY $uid. $displayName");
    _userFirestore = await getUser(uid);
    _userFirestore = _userFirestore?.copyWith(displayName: displayName);

    print("_userFirestore: $_userFirestore");
    await _dataUserService.updateUserToFirestore(_userFirestore!);
  }

  String getPhotoURL() {
    return _userFirestore?.photoURL ?? '';
  }

  Future<UserFirestore?> getUser(String uid) async {
    return await _dataUserService.getUserFromFirestore(uid);
  }

  Future<void> synchroDisplayNameWithFirestore(User user) async {

    print("synchroDisplayNameWithFirestore ${user.displayName}");
    _userFirestore = await getUser(user.uid);
    if (_userFirestore != null) {
      if (_userFirestore!.displayName.isEmpty ||
          _userFirestore!.displayName == "" ||
          _userFirestore!.displayName != user.displayName
      ) {
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
