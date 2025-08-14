import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/repository/auth_repository.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/user_firestore.dart';
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
  }



  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      Logger.Pink.log("AuthBloc: AppStarted event received. Checking current user...");
      final firebaseUser = await _authRepository.currentUser;

      if (firebaseUser != null) {
        Logger.Pink.log("AuthBloc: User found with UID ${firebaseUser.uid}. Fetching profile...");
        final userProfile = await _dataUserRepository.getUser(firebaseUser.uid);
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


  Future<void> _onAuthLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final firebaseUser = event.user;
      Logger.Pink.log("AuthBloc: Événement AuthLoggedIn reçu pour l'UID ${firebaseUser.uid}.");
      UserFirestore? userProfile = await _dataUserRepository.getUser(firebaseUser.uid);
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
          fcmTokens: fcmTokens, // On inclut le token FCM !
        );
        Logger.Pink.log('userProfile : $userProfile');
        // 3. Sauvegarder ce nouveau profil complet.
        await _dataUserRepository.saveUser(userProfile);
        Logger.Pink.log("AuthBloc: Nouveau profil COMPLET sauvegardé pour l'UID ${firebaseUser.uid}.");

      } else {
        // Le profil existe déjà. C'est une reconnexion (ex: après réinstallation).
        Logger.Pink.log("Le profil existe déjà. C'est une reconnexion (ex: après réinstallation)");
        // BONNE PRATIQUE : Mettre à jour le token FCM au cas où il aurait changé.
        Logger.Pink.log("AuthBloc: Profil utilisateur trouvé. Vérification du token FCM.");
        final currentToken = await FcmRepository().geToken();
        if (currentToken != null && !userProfile.fcmTokens.contains(currentToken)) {
          final updatedTokens = List<String>.from(userProfile.fcmTokens)..add(currentToken);
          userProfile = userProfile.copyWith(fcmTokens: updatedTokens);
          // `saveUser` doit utiliser `merge: true` pour ne pas écraser les autres données.
          await _dataUserRepository.saveUser(userProfile);
          Logger.Pink.log("AuthBloc: Token FCM mis à jour pour l'UID ${firebaseUser.uid}.");
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
  Future<void> _handleAuthenticationSuccess(UserCredential? userCredential, Emitter<AuthState> emit) async {
    if (userCredential?.user != null) {
      UserFirestore? userProfile =
      await _dataUserRepository.getUser(userCredential!.user!.uid);
      if (userProfile == null) {
        userProfile = await UserFirestore.fromUserCredential(userCredential);
        await _dataUserRepository.saveUser(userProfile);
      }
      emit(AuthAuthenticated(userProfile));
    } else {
      emit(AuthError(message: "auth_error_echoue"));
    }
  }





}
