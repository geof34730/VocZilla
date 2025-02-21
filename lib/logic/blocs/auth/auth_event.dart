// lib/logic/blocs/auth/auth_event.dart
abstract class AuthEvent {}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String language;

  SignUpRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.language,
  });
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested({required this.email, required this.password});
}

class GoogleSignInRequested extends AuthEvent {}

class FacebookSignInRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}

