// lib/logic/blocs/auth/auth_bloc.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/repository/auth_repository.dart';
import '../../../core/utils/errorMessage.dart';
import '../../../data/models/user_firestore.dart';
import '../../../data/repository/data_user_repository.dart';
import '../../../data/repository/user_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
class AuthProfileUpdateSuccess extends AuthState {
  final UserFirestore updatedUser;
  AuthProfileUpdateSuccess(this.updatedUser);
}
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final DataUserRepository _dataUserRepository;

  AuthBloc({
    required AuthRepository authRepository,
    required DataUserRepository dataUserRepository,
  })  : _authRepository = authRepository,
        _dataUserRepository = dataUserRepository,
        super(AuthInitial()) {
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
          pseudo: event.pseudo,
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
        emit(AuthError(message: "Une erreur est survenue lors de la déconnexion."));
      }
    });

    on<EmailVerifiedEvent>((event, emit) {
      try {
        emit(AuthLoading());
        emit(AuthAuthenticated(user: FirebaseAuth.instance.currentUser));
      } catch (e) {
        emit(AuthError(message: "Une erreur est survenue."));
      }
    });



     on<UpdateUserProfilEvent>((event, emit) async {
      try {
        await _dataUserRepository.updateProfilUserFirestore(
          notificationBloc: event.notificationBloc, // <-- On utilise le BLoC de l'événement
          firstName: event.firstName,
          lastName: event.lastName,
          pseudo: event.pseudo,
        );

        // Mettre à jour l'état de l'utilisateur dans l'AuthBloc si nécessaire
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }

      } catch (e) {
        emit(AuthError(message: "Erreur lors de la mise à jour du profil: ${e.toString()}"));
      }
    });
  }
}
