// lib/logic/blocs/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        print("LoginRequested event received 1");
        final user = await authRepository.signUpWithEmail(
          email: event.email,
          password: event.password,
          firstName: event.firstName,
          lastName: event.lastName,
          language: event.language,
        );
        emit(AuthAuthenticated(user: user));
      } catch (e) {
        print("*********************LoginRequested event received 2");
        emit(AuthError(message: e.toString()));
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
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });

    on<GoogleSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signInWithGoogle();
        emit(AuthAuthenticated(user: user));
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });

    on<FacebookSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signInWithFacebook();
        emit(AuthAuthenticated(user: user));
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });

    on<SignOutRequested>((event, emit) async {
      print("**********************************LogoutRequested event received");
      await authRepository.signOut();
      emit(AuthUnauthenticated());
    });
  }
}
