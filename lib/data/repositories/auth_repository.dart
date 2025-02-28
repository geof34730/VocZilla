// lib/data/repositories/auth_repository.dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vobzilla/data/repositories/data_user_repository.dart';
import '../../core/utils/crypt.dart';
import '../models/user_firestore.dart';



class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<User?> signUpWithEmail({required String email,required String password,required String firstName,required String lastName}) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    userCredential.user?.updateDisplayName('$firstName $lastName');
    return userCredential.user;
  }

  Future<User?> signInWithEmail({required String email,required String password,}) async {
    UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    dataUserRepository.createUser(userCredential: userCredential);
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
    dataUserRepository.createUser(userCredential: userCredential);
    return userCredential.user;
  }

  Future<User?> signInWithFacebook() async {
    final rawNonce = localGenerateNonce();
    final nonce = sha256ofString(rawNonce);
    final LoginResult loginResult = await FacebookAuth.instance.login(
      loginTracking: LoginTracking.limited,
      nonce: nonce,
      permissions: ['email', 'public_profile'],
      ).catchError((onError) {
        if (kDebugMode) {
          //print(onError);
        }
        throw Exception(onError.message);
      }
    );
    if (loginResult.accessToken == null) {
      throw Exception(loginResult.message);
    }
    OAuthCredential facebookAuthCredential;
    //print("tokenType: ${loginResult.accessToken!.type}");
    if (Platform.isIOS) {
      switch (loginResult.accessToken!.type) {
        case AccessTokenType.classic:
          final token = loginResult.accessToken as ClassicToken;
          facebookAuthCredential = FacebookAuthProvider.credential(
            token.authenticationToken!,
          );
          break;
        case AccessTokenType.limited:
          final token = loginResult.accessToken as LimitedToken;
          facebookAuthCredential = OAuthCredential(
            providerId: 'facebook.com',
            signInMethod: 'oauth',
            idToken: token.tokenString,
            rawNonce: rawNonce,
          );
          break;
      }
    } else {
      facebookAuthCredential = FacebookAuthProvider.credential(
        loginResult.accessToken!.tokenString,
      );
    }
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    dataUserRepository.createUser(userCredential: userCredential);
    return userCredential.user;
  }

  Future<User?> signInWithApple() async {
    try {
      // Demander l'autorisation de connexion avec Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Créer un credential OAuth pour Firebase
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Se connecter avec Firebase
      UserCredential userCredential =await _firebaseAuth.signInWithCredential(oauthCredential);
      dataUserRepository.createUser(userCredential: userCredential);
      return userCredential.user;
    } catch (e) {
      print("Error during Apple sign-in: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
  }
}






