import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/repository/auth_repository.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/user_firestore.dart';
import '../../../data/repository/data_user_repository.dart';
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

  /// Gère la logique lorsqu'un utilisateur se connecte avec succès via Firebase.
  /// Cette méthode récupère le profil correspondant depuis Firestore,
  /// et en crée un s'il n'existe pas.
  Future<void> _onAuthLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) async {
    // Optionnel mais recommandé : émettre un état de chargement pendant la récupération du profil.
    emit(AuthLoading());
    try {
      final firebaseUser = event.user;
      Logger.Pink.log("AuthBloc: Événement AuthLoggedIn reçu pour l'UID ${firebaseUser.uid}.");

      // 1. Tenter de récupérer le profil utilisateur depuis Firestore.
      UserFirestore? userProfile = await _dataUserRepository.getUser(firebaseUser.uid);

      // 2. Si aucun profil n'existe, c'est un nouvel utilisateur (comme notre invité).
      //    Il faut créer un document de profil par défaut pour lui.
      if (userProfile == null) {
        Logger.Pink.log("AuthBloc: Aucun profil dans Firestore. Création d'un nouveau profil par défaut.");

        // Créer un nouvel objet UserFirestore à partir des données de l'utilisateur Firebase.
        // Assurez-vous que votre modèle UserFirestore a un constructeur qui peut gérer cela.
        userProfile = UserFirestore(
          uid: firebaseUser.uid,
          pseudo: firebaseUser.displayName ?? "", // Sera null pour les utilisateurs anonymes
          photoURL: firebaseUser.photoURL ?? "",
          createdAt: firebaseUser.metadata.creationTime
        );

        // Sauvegarder le nouveau profil dans Firestore
        await _dataUserRepository.saveUser(userProfile);
        Logger.Pink.log("AuthBloc: Nouveau profil sauvegardé dans Firestore pour l'UID ${firebaseUser.uid}.");
      }

      // 3. Maintenant que nous avons un userProfile valide, émettre l'état authentifié.
      //    L'interface utilisateur écoutera ce changement d'état et naviguera vers l'écran d'accueil.
      emit(AuthAuthenticated(userProfile));
      Logger.Pink.log("AuthBloc: Émission de AuthAuthenticated avec le profil utilisateur.");

    } catch (e, stackTrace) {
      Logger.Pink.log("AuthBloc: ERREUR CRITIQUE durant AuthLoggedIn: $e\n$stackTrace");
      // Informer l'UI que quelque chose s'est mal passé lors de la récupération du profil.
      emit(AuthError(message: "auth_error_profile_fetch_failed"));
    }
  }

  /// Gestionnaire pour la déconnexion.
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
