// lib/data/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String language,
  }) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Update user profile
    await userCredential.user?.updateDisplayName('$firstName $lastName');
    // You can also store additional user information in Firestore or Realtime Database
    return userCredential.user;
  }

  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<User?> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
/*
    if (result.status == LoginStatus.success) {
      final AccessToken? accessToken = result.accessToken;
      if (accessToken != null && accessToken.token != null) {
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider
            .credential(accessToken.token!);
        UserCredential userCredential = await _firebaseAuth.signInWithCredential(facebookAuthCredential);
        return userCredential.user;
      } else {
        throw Exception('Failed to obtain access token from Facebook');
      }
    } else {
      throw Exception('Failed to sign in with Facebook: ${result.message}');
    }*/
  }


  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();

  }
}

