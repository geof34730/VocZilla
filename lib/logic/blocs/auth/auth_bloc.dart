// lib/logic/blocs/auth/auth_bloc.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/repository/auth_repository.dart';
import '../../../core/utils/errorMessage.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signUpWithEmail(
          email: event.email,
          password: event.password,
          firstName: event.firstName,
          lastName: event.lastName,
        );
        emit(AuthAuthenticated(user: user));

      } on FirebaseAuthException catch (e) {
        emit(AuthError(message: errorFirebaseMessage(e)));
      }
    });

    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signInWithEmail(
          email: event.email,
          password: event.password,
        );
        emit(AuthAuthenticated(user: user));
      } on FirebaseAuthException catch (e) {
        emit(AuthError(message: errorFirebaseMessage(e)));
      }
    });

    on<GoogleSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signInWithGoogle();
        emit(AuthAuthenticated(user: user));
      } on FirebaseAuthException catch (e) {
        emit(AuthError(message: errorFirebaseMessage(e)));
      }
    });

    on<FacebookSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signInWithFacebook();
        emit(AuthAuthenticated(user: user));
      } on FirebaseAuthException catch (e) {
        emit(AuthError(message: errorFirebaseMessage(e)));
      }
    });

    on<AppleSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signInWithApple();
        emit(AuthAuthenticated(user: user));
      } on FirebaseAuthException catch (e) {
        emit(AuthError(message: errorFirebaseMessage(e)));
      }
    });

    on<SignOutRequested>((event, emit) async {
      try {
      await authRepository.signOut();
      emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError(message: errorFirebaseMessage(e)));
      }
    });

    on<EmailVerifiedEvent>((event, emit) {
      try {
        emit(AuthLoading());
        emit(AuthAuthenticated(user: FirebaseAuth.instance.currentUser));
      } catch (e) {
        emit(AuthError(message: errorFirebaseMessage(e)));
      }
    });

    on<UpdateUserEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signInWithApple();
        emit(AuthAuthenticated(user: user));
      } on FirebaseAuthException catch (e) {
        emit(AuthError(message: errorFirebaseMessage(e)));
      }
      emit(AuthAuthenticated(user: event.user));
    });

    on<UpdateDisplayNameEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        authRepository.updateDisplayName(displayName: event.displayName);
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseAuth.instance.currentUser?.updateDisplayName(event.displayName);
          emit(AuthAuthenticated(user: FirebaseAuth.instance.currentUser));
        }
      } catch (e) {
        emit(AuthError(message: errorFirebaseMessage(e)));
      }
    });
  }
}
