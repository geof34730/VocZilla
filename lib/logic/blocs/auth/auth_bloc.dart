import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/data/repository/auth_repository.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/user_firestore.dart';
import '../../../data/models/vocabulary_user.dart';
import '../../../data/repository/data_user_repository.dart';
import '../../../data/repository/fcm_repository.dart';
import '../../../data/services/localstorage_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final DataUserRepository _dataUserRepository;

  AuthBloc({
    required AuthRepository authRepository,
    required DataUserRepository dataUserRepository,
  })  : _authRepository = authRepository,
        _dataUserRepository = dataUserRepository,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthLoggedOut>(_onAuthLoggedOut);
    on<SignOutRequested>(_onSignOutRequested);
    on<UpdateUserProfilEvent>(_onUpdateUserProfilEvent);
  }



  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      Logger.Pink.log("AuthBloc: AppStarted event received. Checking current user...");
      final firebaseUser = await _authRepository.currentUser;

      if (firebaseUser != null) {
        Logger.Pink.log("AuthBloc: User found with UID ${firebaseUser.uid}. Fetching profile...");
        final userProfile = await _dataUserRepository.getUser(uid:firebaseUser.uid);
        if (userProfile != null) {
          Logger.Pink.log("AuthBloc: User profile found. Emitting AuthAuthenticated.");
          emit(AuthAuthenticated(userProfile));
        } else {
          Logger.Pink.log("AuthBloc: User profile not found in Firestore for a valid Firebase user. Signing out.");
          await _authRepository.signOut();
          emit(AuthUnauthenticated());
        }
      } else {
        Logger.Pink.log("AuthBloc: No user found. Emitting AuthUnauthenticated.");
        emit(AuthUnauthenticated());
      }
    } catch (e, stackTrace) { // MODIFICATION : On capture l'erreur et la stack trace
      // AFFICHE L'ERREUR DANS LA CONSOLE POUR LE DÉBOGAGE
      Logger.Pink.log("AuthBloc: CRITICAL ERROR during AppStarted: $e , $stackTrace");
      // On peut émettre un état d'erreur pour que l'UI puisse réagir
      emit(AuthError(message: "init_failed"));
    }
  }
  Future<void> _onUpdateUserProfilEvent(
      UpdateUserProfilEvent event,
      Emitter<AuthState> emit,
      ) async {
    // Il est crucial de s'assurer que nous mettons à jour le profil de l'utilisateur actuellement connecté.
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      try {
        // Optionnel : émettre un état de chargement pour l'UI
        // emit(AuthLoading()); // Attention, cela pourrait faire disparaître le formulaire.
        // Une meilleure approche serait d'avoir un état de chargement spécifique pour la mise à jour.

        Logger.Pink.log("AuthBloc: Mise à jour du profil pour l'UID ${currentState.userProfile.uid}...");

        // Créez une copie du profil actuel avec les nouvelles données
        final updatedProfile = currentState.userProfile.copyWith(
          pseudo: event.pseudo,
          // Si un nouvel avatar est fourni, on le prend, sinon on garde l'ancien.
          imageAvatar: event.imageAvatar ?? currentState.userProfile.imageAvatar,
        );

        // Sauvegardez le profil mis à jour dans Firestore
        await _dataUserRepository.saveUser(user:updatedProfile,mergeData: true);

        // Mettez également à jour le profil dans le stockage local
        await LocalStorageService().saveUser(updatedProfile);

        Logger.Pink.log("AuthBloc: Profil mis à jour avec succès. Émission de AuthAuthenticated.");

        // Émettez l'état authentifié avec le profil mis à jour pour que toute l'application soit synchronisée.
        emit(AuthAuthenticated(updatedProfile));

      } catch (e, stackTrace) {
        Logger.Pink.log("AuthBloc: ERREUR lors de la mise à jour du profil: $e\n$stackTrace");
        emit(AuthError(message: "profile_update_failed"));
      }
    } else {
      // Ce cas ne devrait pas arriver si l'utilisateur est sur la page de profil,
      // mais c'est une bonne pratique de le gérer.
      Logger.Pink.log("AuthBloc: Tentative de mise à jour du profil sans être authentifié.");
      emit(AuthError(message: "user_not_authenticated"));
    }
  }


  Future<void> _onAuthLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final firebaseUser = event.user;
      Logger.Pink.log("AuthBloc: Événement AuthLoggedIn reçu pour l'UID ${firebaseUser.uid}.");
      UserFirestore? userProfile = await _dataUserRepository.getUser(uid:firebaseUser.uid);



      if (userProfile == null) {
        // Le profil n'existe pas dans Firestore. C'est une VRAIE première connexion pour cet UID.
        Logger.Pink.log("AuthBloc: Aucun profil dans Firestore. Création d'un nouveau profil COMPLET.");

        // 1. Récupérer le token FCM pour l'inclure dès la création.
        final fcmTokens = await FcmRepository().getListFcmToken();

        // 2. Créer un profil COMPLET en utilisant les valeurs par défaut de votre modèle.
        Logger.Pink.log('Créer un profil COMPLET en utilisant les valeurs par défaut de votre modèle');
        userProfile = UserFirestore(
          uid: firebaseUser.uid,
          photoURL: firebaseUser.photoURL ?? '',
          imageAvatar: '', // Pas d'avatar pour un nouvel invité.
          createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
          fcmTokens: fcmTokens,
        );
        Logger.Pink.log('userProfile : $userProfile');
        // 3. Sauvegarder ce nouveau profil complet.
        await _dataUserRepository.saveUser(user: userProfile, mergeData: false);
        Logger.Pink.log("AuthBloc: Nouveau profil COMPLET sauvegardé pour l'UID ${firebaseUser.uid}.");

      } else {
        // Le profil existe déjà. C'est une reconnexion (ex: après réinstallation).
        Logger.Pink.log("Le profil existe déjà. C'est une reconnexion (ex: après réinstallation)");
        // BONNE PRATIQUE : Mettre à jour le token FCM au cas où il aurait changé.
        Logger.Pink.log("AuthBloc: Profil utilisateur trouvé. Vérification du token FCM.");
        final currentToken = await FcmRepository().geToken();
        if (!userProfile.fcmTokens.contains(currentToken)) {
          Logger.Cyan.log('condition 1');
          final updatedTokens = List<String>.from(userProfile.fcmTokens)..add(currentToken);
          userProfile = userProfile.copyWith(fcmTokens: updatedTokens);
          // `saveUser` doit utiliser `merge: true` pour ne pas écraser les autres données.
          await _dataUserRepository.saveUser(user: userProfile, mergeData: true);
          Logger.Pink.log("AuthBloc: Token FCM mis à jour pour l'UID ${firebaseUser.uid}.");
        }
        else{
          Logger.Cyan.log('condition 2');
          Logger.Cyan.log(userProfile);

          await _dataUserRepository.saveUser(user: userProfile, mergeData: true);
        }
      }
      // --- FIN DE LA CORRECTION ---
      emit(AuthAuthenticated(userProfile));
      Logger.Pink.log("AuthBloc: Émission de AuthAuthenticated avec le profil utilisateur.");
    } catch (e, stackTrace) {
      Logger.Pink.log("AuthBloc: ERREUR CRITIQUE durant AuthLoggedIn: $e\n$stackTrace");
      emit(AuthError(message: "auth_error_profile_fetch_failed"));
    }
  }

  Future<void> _onAuthLoggedOut(AuthLoggedOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      // Gérer l'erreur de déconnexion si nécessaire
      emit(AuthError(message: "auth_error_deconnect"));
    }
  }


  Future<void> _onSignOutRequested( SignOutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.signOut();
      await LocalStorageService().clearUser();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'auth-error-deconnect'));
    }
  }



}
