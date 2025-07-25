// lib/logic/blocs/auth/auth_state.dart
import 'package:equatable/equatable.dart';
import '../../../data/models/user_firestore.dart';

// 1. Faire étendre la classe de base de Equatable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserFirestore userProfile;

  // 2. Supprimer le mot-clé 'const' car userProfile n'est pas une constante de compilation.
  AuthAuthenticated(this.userProfile);

  @override
  List<Object> get props => [userProfile];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
  @override
  List<Object> get props => [message];
}

class AuthSuccess extends AuthState {
  final String message;
 const AuthSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class AuthProfileUpdated extends AuthAuthenticated {
  AuthProfileUpdated(UserFirestore userProfile) : super(userProfile);
}
