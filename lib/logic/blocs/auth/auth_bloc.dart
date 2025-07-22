// lib/logic/blocs/auth/auth_bloc.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/repository/auth_repository.dart';
import '../../../core/utils/errorMessage.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/user_firestore.dart';
import '../../../data/repository/data_user_repository.dart';
import '../../../data/repository/fcm_repository.dart';
import '../notification/notification_event.dart';
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
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<FacebookSignInRequested>(_onFacebookSignInRequested);
    on<AppleSignInRequested>(_onAppleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<UpdateUserProfilEvent>(_onUpdateUserProfilEvent);
    on<EmailVerifiedEvent>(_onUserEmailVerified);
    on<AuthErrorCleared>(_onAuthErrorCleared);
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _authRepository.signUpWithEmail(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        pseudo: event.pseudo,
      );

      final user = userCredential.user;
      if (user != null) {
        // 2. Crée l'objet UserFirestore avec TOUTES les informations de l'événement.
        final newUserProfile = await UserFirestore.fromSignUp(
          user: user,
          email: event.email,
          firstName: event.firstName,
          lastName: event.lastName,
          pseudo: event.pseudo,
        );
        // 3. Sauvegarde le nouveau profil complet dans Firestore.
        await _dataUserRepository.saveUser(newUserProfile);
        // 4. Émet l'état authentifié avec le profil qui vient d'être créé.
        emit(AuthAuthenticated(newUserProfile));
      } else {
        // Ce cas est peu probable si signUpWithEmail ne lève pas d'exception,
        // mais c'est une bonne pratique de le gérer.
        emit(AuthError(message: "La création de l'utilisateur a échoué."));
      }
    } on FirebaseAuthException catch (e) {
      await _handleAuthException(e, emit);
    } catch (e) {
      emit(AuthError(message: "Une erreur inconnue est survenue lors de l'inscription."));
    }
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      await _handleAuthenticationSuccess(userCredential, emit);
    } on FirebaseAuthException catch (e) {
      await _handleAuthException(e, emit);
    } catch (e) {
      emit(AuthError(message: "Une erreur inconnue est survenue lors de la connexion."));
    }
  }

  Future<void> _onAuthErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit,) async {
    emit(AuthUnauthenticated());
  }

  Future<void> _onUserEmailVerified( EmailVerifiedEvent event,Emitter<AuthState> emit,) async {
    final currentState = state;
    // On agit uniquement si l'utilisateur est authentifié
    if (currentState is AuthAuthenticated) {
      // Si l'email est déjà marqué comme vérifié, on ne fait rien
      if (currentState.userProfile.isEmailVerified) return;

      // On crée une copie du profil avec le statut de vérification mis à jour
      final updatedProfile = currentState.userProfile.copyWith(
        isEmailVerified: true,
      );

      try {
        // On sauvegarde cette mise à jour dans Firestore
        await _dataUserRepository.saveUser(updatedProfile);
        // On émet le nouvel état, ce qui déclenchera le BlocListener dans l'UI
        emit(AuthAuthenticated(updatedProfile));
      } catch (e) {
        Logger.Red.log("Erreur lors de la mise à jour du profil après vérification: $e");
        // Vous pouvez gérer l'erreur ici si nécessaire
      }
    }
  }

  Future<void> _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _authRepository.signInWithGoogle();
      await _handleAuthenticationSuccess(userCredential, emit);
    } on FirebaseAuthException catch (e) {
      // NOUVEAU : Appel du gestionnaire d'erreur centralisé
      await _handleAuthException(e, emit);
    } catch (e) {
      emit(AuthError(
          message: "Une erreur inconnue est survenue avec la connexion Google."));
    }
  }

  Future<void> _onFacebookSignInRequested(FacebookSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _authRepository.signInWithFacebook();
      await _handleAuthenticationSuccess(userCredential, emit);
    } on FirebaseAuthException catch (e) {
      // NOUVEAU : Appel du gestionnaire d'erreur centralisé
      await _handleAuthException(e, emit);
    } catch (e) {
      emit(AuthError(
          message: "Une erreur inconnue est survenue avec la connexion Facebook."));
    }
  }

  Future<void> _onAppleSignInRequested( AppleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _authRepository.signInWithApple();
      await _handleAuthenticationSuccess(userCredential, emit);
    } on FirebaseAuthException catch (e) {
      // NOUVEAU : Appel du gestionnaire d'erreur centralisé
      await _handleAuthException(e, emit);
    } catch (e) {
      emit(AuthError( message: "Une erreur inconnue est survenue avec la connexion Apple."));
    }
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      final firebaseUser = _authRepository.currentUser;
      if (firebaseUser != null) {
        final userProfile = await _dataUserRepository.getUser(firebaseUser.uid);
        if (userProfile != null) {
          emit(AuthAuthenticated(userProfile));
        } else {
          await _authRepository.signOut();
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignOutRequested( SignOutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(
          message: "Une erreur est survenue lors de la déconnexion."));
    }
  }

  Future<void> _onUpdateUserProfilEvent(UpdateUserProfilEvent event, Emitter<AuthState> emit) async {
    if (state is AuthAuthenticated) {
      final currentProfile = (state as AuthAuthenticated).userProfile;
      try {
        await _dataUserRepository.updateProfilUserFirestore(
          firstName: event.firstName,
          lastName: event.lastName,
          pseudo: event.pseudo,
          imageAvatar: event.imageAvatar
        );
        final updatedProfile =
        await _dataUserRepository.getUser(currentProfile.uid);
        if (updatedProfile != null) {
          emit(AuthAuthenticated(updatedProfile));
          event.notificationBloc.add(ShowNotification(
            message: "Profil mis à jour avec succès !",
            backgroundColor: Colors.green,
          ));
        } else {
          throw Exception("Impossible de récupérer le profil mis à jour.");
        }
      } catch (e) {
        event.notificationBloc.add(ShowNotification(
          message: "Erreur lors de la mise à jour du profil : ${e.toString()}",
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _handleAuthenticationSuccess(UserCredential? userCredential, Emitter<AuthState> emit) async {
    if (userCredential?.user != null) {
      Logger.Green.log("1. Succès d'authentification. Traitement du profil...");
      UserFirestore? userProfile =
      await _dataUserRepository.getUser(userCredential!.user!.uid);
      Logger.Green.log("2. Profil récupéré depuis le repo. Est-il null ? ${userProfile == null}");
      if (userProfile == null) {
        Logger.Yellow.log("3. Le profil est null. Création d'un nouveau profil...");
        userProfile = await UserFirestore.fromUserCredential(userCredential);
        Logger.Yellow.log("4. Nouveau profil créé. Sauvegarde dans le repo...");
        await _dataUserRepository.saveUser(userProfile);
        Logger.Yellow.log("5. Nouveau profil sauvegardé.");
      }
      Logger.Green.log("6. Émission de l'état AuthAuthenticated.");
      emit(AuthAuthenticated(userProfile));
    } else {
      emit(AuthError(
          message: "L'authentification a échoué, veuillez réessayer."));
    }
  }

  Future<void> _handleAuthException(FirebaseAuthException e, Emitter<AuthState> emit) async {
    emit(AuthError(message: errorFirebaseMessage(e)));
  }
}
