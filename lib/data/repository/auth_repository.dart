import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../logic/blocs/auth/auth_bloc.dart';
import '../../logic/blocs/auth/auth_event.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/data_user_service.dart';
import 'data_user_repository.dart';
bool _emailVerified = false;
bool _displayName = false;


class AuthRepository {

  final AuthService _authService = AuthService();

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    UserCredential? userCredential = await _authService.signUpWithEmail(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    userCredential?.user?.updateDisplayName('$firstName $lastName');
    dataUserRepository.createUser(userCredential: userCredential);
    return userCredential?.user;
  }

  Future<User?> signInWithEmail({required String email, required String password}) async {
    UserCredential? userCredential = await _authService.signInWithEmail(email:email, password:password);
    dataUserRepository.createUser(userCredential: userCredential);
    return userCredential?.user;
  }

  Future<User> signInWithGoogle() async {
    UserCredential? userCredential= await _authService.signInWithGoogle();
    dataUserRepository.createUser(userCredential: userCredential);
    return userCredential!.user!;
  }

  Future<User> signInWithFacebook() async {
    UserCredential? userCredential= await _authService.signInWithFacebook();
    dataUserRepository.createUser(userCredential: userCredential);
    return userCredential!.user!;
  }

  Future<User?> signInWithApple() async {
    print('signing in with apple');
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

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      dataUserRepository.createUser(userCredential: userCredential);
      print('userCredential: ${userCredential.user}');
      return userCredential.user;
    } catch (e) {
      print("Error during Apple sign-in: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<User> getUser() async {
    return FirebaseAuth.instance.currentUser!;
  }

  Future<void> updateDisplayName({required String displayName}) async {
    try {
      User? user = await FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseAuth.instance.currentUser?.updateDisplayName(displayName);
        await FirebaseAuth.instance.currentUser?.reload();
        await dataUserRepository.updateDisplayName(displayName:displayName,uid: FirebaseAuth.instance.currentUser?.uid);
      }
    } catch (e) {
      print("Erreur lors de la mise à jour du DisplayName: $e");
    }
  }

  Future<void> checkEmailVerifiedPeriodically({required AuthBloc authBloc}) async {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        user = FirebaseAuth.instance.currentUser;
        if (user!.emailVerified && !_emailVerified) {
          _displayName=true;
          timer.cancel();
          authBloc.add(UpdateUserEvent(user));
          authBloc.add(EmailVerifiedEvent());
          timer.cancel();
        }
      }
    });
  }

  Future<void> setPersistence() async {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
}
