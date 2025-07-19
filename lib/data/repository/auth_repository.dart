import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../core/utils/logger.dart';
import '../../logic/blocs/auth/auth_bloc.dart';
import '../../logic/blocs/auth/auth_event.dart';
import '../../logic/blocs/notification/notification_bloc.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    required String pseudo
  }) async { UserCredential? userCredential = await _authService.signUpWithEmail(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      pseudo: pseudo,
      );


    Logger.Green.log('userCredential go createUserFirestore: $firstName');
    dataUserRepository.createUserFirestore(
        userCredential: userCredential,
        firstName: firstName,
        lastName: lastName,
        pseudo: pseudo

    );
    return userCredential?.user;
  }

  Future<User?> signInWithEmail({required String email, required String password}) async {
    UserCredential? userCredential = await _authService.signInWithEmail(email:email, password:password);
    //dataUserRepository.createUserFirestore(userCredential: userCredential);
    return userCredential?.user;
  }

  Future<User> signInWithGoogle() async {
    UserCredential? userCredential= await _authService.signInWithGoogle();
    dataUserRepository.createUserFirestore(userCredential: userCredential);
    return userCredential!.user!;
  }

  Future<User> signInWithFacebook() async {
    UserCredential? userCredential= await _authService.signInWithFacebook();
    Logger.Cyan.log('userCredential: $userCredential');
    dataUserRepository.createUserFirestore(userCredential: userCredential);
    return userCredential!.user!;
  }

  Future<User?> signInWithApple() async {
    Logger.Cyan.log('signing in with apple');
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
      dataUserRepository.createUserFirestore(userCredential: userCredential);
      Logger.Cyan.log('userCredential: ${userCredential.user}');
      return userCredential.user;
    } catch (e) {
      Logger.Red.log("Error during Apple sign-in: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<User?> getUserFirebase() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> updateProfil({required NotificationBloc notificationBloc,required String firstName,required String lastName, required String pseudo}) async {
    if (FirebaseAuth.instance.currentUser != null) {
      try {
          await dataUserRepository.updateProfilUserFirestore(
              firstName: firstName,
              lastName: lastName,
              pseudo: pseudo,
              notificationBloc:notificationBloc
          );

      } catch (e) {
        Logger.Red.log("Erreur lors de la mise à jour du Profil: $e");
      }
    }
  }

  Future<void> checkEmailVerifiedPeriodically({required AuthBloc authBloc}) async {
    if (FirebaseAuth.instance.currentUser != null) {
      Timer.periodic(Duration(seconds: 5), (timer) async {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.reload();
          user = FirebaseAuth.instance.currentUser;
          if (user!.emailVerified && !_emailVerified) {
            _displayName = true;
            timer.cancel();
            authBloc.add(UpdateUserEvent(user));
            authBloc.add(EmailVerifiedEvent());
            timer.cancel();
          }
        }
      });
    }
  }

  Future<void> setPersistence() async {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
}
