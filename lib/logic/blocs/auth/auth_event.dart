// lib/logic/blocs/auth/auth_event.dart
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  SignUpRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,

  });
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested({required this.email, required this.password});
}

class GoogleSignInRequested extends AuthEvent {}

class FacebookSignInRequested extends AuthEvent {}

class AppleSignInRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}

class EmailVerifiedEvent extends AuthEvent {}

class DisplayNameUpdateEvent extends AuthEvent {}

class UpdateUserEvent extends AuthEvent {
  final User user;

  const UpdateUserEvent(this.user);

  @override
  List<Object> get props => [user];
}

class UpdateDisplayNameEvent extends AuthEvent {
  final String displayName;
  const UpdateDisplayNameEvent(this.displayName);

  @override
  List<Object> get props => [displayName];
}
