// lib/data/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';

import '../../core/utils/crypt.dart';
import '../../core/utils/logger.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential> signUpWithEmail(
      {required String email,
        required String password,
        required String firstName,
        required String lastName,
        required String pseudo}) async {
    UserCredential userCredential =
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Note: updateDisplayName est asynchrone mais on n'a pas besoin de l'attendre ici.
    //userCredential.user?.updateDisplayName('$firstName $lastName $pseudo');
    return userCredential;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    UserCredential userCredential =
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // L'utilisateur a annulé la connexion
      throw FirebaseAuthException(
          code: 'sign-in-cancelled', message: 'Sign in was cancelled');
    }
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential userCredential =
    await _firebaseAuth.signInWithCredential(credential);
    return userCredential;
  }

  Future<UserCredential> signInWithFacebook() async {
    final rawNonce = localGenerateNonce();
    final nonce = sha256ofString(rawNonce);
    final LoginResult loginResult = await FacebookAuth.instance.login(
      loginTracking: LoginTracking.limited,
      nonce: nonce,
      permissions: ['email', 'public_profile'],
    );

    if (loginResult.status != LoginStatus.success ||
        loginResult.accessToken == null) {
      throw Exception(loginResult.message ?? 'Facebook login failed.');
    }

    OAuthCredential facebookAuthCredential =
    FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

    UserCredential userCredential =
    await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    return userCredential;
  }

  Future<UserCredential> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Se connecter avec Firebase et retourner le résultat
      return await _firebaseAuth.signInWithCredential(oauthCredential);
    } catch (e) {
      Logger.Red.log("Error during Apple sign-in: $e");
      // Propage l'erreur pour que le BLoC puisse la gérer et afficher un message.
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
  }
}
