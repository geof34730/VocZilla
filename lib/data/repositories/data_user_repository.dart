import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_firestore.dart';

class DataUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserCredential? _userCredential;
  UserFirestore? _userFirestore;
  bool _userExist =false;

  UserFirestore? getUserFirestore(){
      return UserFirestore.fromUserCredential(_userCredential!);
  }

  Future<void> createUser({required UserCredential userCredential}) async {
    _userCredential = userCredential;
    _userFirestore = getUserFirestore();
    _userExist = await getUserExist();
    if (_userFirestore != null){
      if (_userExist) {
        await _firestore.collection('users').doc(_userFirestore?.uid).set(
            _userFirestore!.toJson()
        );
      }
    }
  }

  Future<bool> getUserExist() async {
    bool exist = false;
    try {
      await _firestore.collection('users').doc(_userCredential?.user!.uid).get().then((doc) {
        exist = doc.exists;
      });
      return exist;
    } catch (e) {
      throw e;
    }
  }
}
DataUserRepository dataUserRepository = DataUserRepository();
