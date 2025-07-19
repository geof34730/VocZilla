import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/utils/logger.dart';
import '../../logic/blocs/notification/notification_bloc.dart';
import '../../logic/blocs/notification/notification_event.dart';
import '../models/user_firestore.dart';
import '../services/data_user_service.dart';
import 'fcm_repository.dart';
import '../services/localstorage_service.dart';
class DataUserRepository {
  final DataUserService _dataUserService = DataUserService();
  UserFirestore? _userFirestore;
  final LocalStorageService _localStorageService = LocalStorageService();
  Future<void> createUserFirestore({
    required UserCredential? userCredential,
    String? firstName,
    String? lastName,
    String? pseudo,
  }) async {
    Logger.Yellow.log("C DataUserRepository $userCredential");
    if (userCredential == null) return;
    final String uid = userCredential.user!.uid;
    bool userExists = await _dataUserService.checkUserFirestoreExists(uid);
    UserFirestore userFirestore = await UserFirestore.fromUserCredential(userCredential);

    final String calculatedDisplayName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    bool defaultVerifiedForGafa = userCredential.user?.providerData.any((
        info) =>  info.providerId == 'facebook.com' ||
        info.providerId == 'google.com' ||
        info.providerId == 'apple.com'
    ) ?? false;

    _userFirestore = userFirestore.copyWith(
        firstName: firstName ?? '',
        lastName: lastName ?? '',
        pseudo: pseudo ?? '',
        displayName: calculatedDisplayName,
        providerId: userCredential.user?.providerData.isNotEmpty == true
            ? userCredential.user?.providerData.first.providerId ?? ''
            : '',
        isEmailVerified:userCredential.user?.emailVerified ?? defaultVerifiedForGafa
    );


    if (!userExists) {
      UserFirestore userFirestore = await UserFirestore.fromUserCredential(userCredential);
      _userFirestore = userFirestore.copyWith(
          firstName: firstName ?? '',
          lastName: lastName ?? '',
          pseudo: pseudo ?? '',
          displayName: calculatedDisplayName,
          providerId: userCredential.user?.providerData.first.providerId ?? '',
          isEmailVerified: userCredential.user?.emailVerified ?? defaultVerifiedForGafa);

      await _dataUserService.saveUserToFirestore(user: _userFirestore!);
      await _localStorageService.saveUser(_userFirestore!); // <-- SAUVEGARDE LOCALE
      Logger.Green.log("New user created and saved locally: ${_userFirestore!.pseudo}");
    } else {
      _userFirestore = await getUserFirestore(uid);
      if (_userFirestore != null) {
        String newToken = await FcmRepository().geToken();

        // Check if the token is already in the list
        bool tokenExists = _userFirestore!.fcmTokens.contains(newToken);
        if (!tokenExists) {
          // Add the new token to the list
          List<String> updatedTokens = List<String>.from(_userFirestore!.fcmTokens);
          updatedTokens.add(newToken);
          // Update the user with the new data
          _userFirestore = _userFirestore!.copyWith(
              fcmTokens: updatedTokens,
              firstName: firstName ?? '',
              lastName: lastName ?? '',
              pseudo: pseudo ?? '',
              displayName: '$firstName ??  $lastName' ?? '',
              providerId: userCredential.user?.providerData.isNotEmpty == true
                  ? userCredential.user?.providerData.first.providerId ?? ''
                  : '',
              isEmailVerified:userCredential.user?.emailVerified ?? defaultVerifiedForGafa
          );
          Logger.Green.log("Updating user in Firestore: $_userFirestore");
          await _dataUserService.updateUserToFirestore(user: _userFirestore!);
          await _localStorageService.saveUser(_userFirestore!); // <-- SAUVEGARDE LOCALE
          Logger.Green.log("Existing user updated and saved locally: ${_userFirestore!.pseudo}");

//          await _dataUserService.updateUserToFirestore(user: _userFirestore!);
        }
        else{
          Logger.Cyan.log("Token already exists");
        }
      }
    }
  }


  Future<UserFirestore> updateProfilUserFirestore({required NotificationBloc notificationBloc , required String lastName, required String firstName,  required String pseudo}) async {

    Logger.Green.log('updateProfilUserFirestore');

    _userFirestore = await _localStorageService.loadUser();

    if (_userFirestore == null) {
      notificationBloc.add(ShowNotification(
        message: "Could not update profile: User not found in local storage.",
        backgroundColor: Colors.red,
      ));
      throw Exception("User not found in local storage");
    }

    // Calculate display name from first and last name
    final String calculatedDisplayName = '$firstName $lastName'.trim();

    _userFirestore = _userFirestore!.copyWith(
      lastName: lastName,
      firstName: firstName,
      pseudo: pseudo,
      displayName: calculatedDisplayName,
    );

    await _dataUserService.updateUserToFirestore(user: _userFirestore!);
    await _localStorageService.saveUser(_userFirestore!);


    Future.delayed(Duration(seconds: 1)).then((_) {
      notificationBloc.add(ShowNotification(
        message: "Utilisateur mis à jour avec succès",
        backgroundColor: Colors.green,
      ));
    });


    return _userFirestore!;
  }


  Future<void> emailVerifiedUpdateUserFirestore() async {
    // Essayer de récupérer l'utilisateur depuis l'instance en mémoire du repository.
    // Si elle est nulle (ex: après un redémarrage de l'app), on la charge depuis le cache.
    _userFirestore ??= await _localStorageService.loadUser();

    if (_userFirestore != null) {
      // Mettre à jour l'instance avec le statut de vérification
      _userFirestore = _userFirestore!.copyWith(
        isEmailVerified: true,
      );

      // Sauvegarder les modifications dans Firestore
      await _dataUserService.updateUserToFirestore(user: _userFirestore!);

      // Mettre à jour également le cache local avec les nouvelles informations
      await _localStorageService.saveUser(_userFirestore!);
    } else {
      // Cas de secours : si l'utilisateur n'est ni en mémoire ni dans le cache,
      // on ne peut rien faire. Un log d'erreur est essentiel ici.
      Logger.Red.log("Could not update email verification status: User not found in repository or local storage.");
    }
  }



  Future<UserFirestore?> getUserFirestore(String uid) async {
    return await _dataUserService.getUserFromFirestore(uid);
  }



}
DataUserRepository dataUserRepository = DataUserRepository();
