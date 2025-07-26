import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/repository/auth_repository.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/user_firestore.dart';
import '../../../data/repository/data_user_repository.dart';
import '../../../data/services/localstorage_service.dart';
import '../notification/notification_event.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
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
        emit(AuthError(message: "auth_error_create_user"));
      }
    } on FirebaseAuthException catch (e) {
      await _handleAuthException(e, emit);
    } catch (e) {
      emit(AuthError(message: "auth_error_register_unknown"));
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
      emit(AuthError(message: "auth_error_connect"));
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
        await _dataUserRepository.saveUser(updatedProfile);
        emit(AuthAuthenticated(updatedProfile));
      } catch (e) {
        Logger.Red.log("Erreur lors de la mise à jour du profil après vérification: $e");
        emit(AuthError(message: "auth_error_update_profil"));
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
      emit(AuthError(message: "auth_error_google"));
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
      emit(AuthError(message: "auth_error_facebook"));
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
      emit(AuthError( message: "auth_error_apple"));
    }
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

  Future<void> _onSignOutRequested( SignOutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.signOut();
      await LocalStorageService().clearUser();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'auth-error-deconnect'));
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
        final updatedProfile =  await _dataUserRepository.getUser(currentProfile.uid);
        if (updatedProfile != null) {
          emit(AuthSuccess(message: "[SuccessBloc/auth_success_update_profile]"));
          emit(AuthProfileUpdated(updatedProfile));
        } else {
          emit(AuthError(message: 'auth_error_update_profil'));
          throw Exception("Impossible de récupérer le profil mis à jour.");
        }
      } catch (e) {
        emit(AuthError(message: 'auth_error_update_profil'));
      }
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

  Future<void> _handleAuthException(FirebaseAuthException e, Emitter<AuthState> emit) async {
    emit(AuthError(message: e.toString()));
  }
}
