// lib/logic/blocs/auth/auth_event.dart
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../notification/notification_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  // CORRECTION : On autorise les objets nuls dans la liste de props.
  // Cela rend la classe de base compatible avec toutes les classes enfants.
  List<Object?> get props => [];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String pseudo;

  SignUpRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.pseudo,
  });

  // On ajoute les props pour que Equatable puisse comparer les instances
  @override
  List<Object> get props => [email, password, firstName, lastName, pseudo];
}

class AppStarted extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class GoogleSignInRequested extends AuthEvent {}

class FacebookSignInRequested extends AuthEvent {}

class AppleSignInRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}

class EmailVerifiedEvent extends AuthEvent {}

class AuthErrorCleared extends AuthEvent {}

class UpdateUserEvent extends AuthEvent {
  final User user;
  const UpdateUserEvent(this.user);
  @override
  List<Object> get props => [user];
}

class UpdateUserProfilEvent extends AuthEvent {
  final String lastName;
  final String firstName;
  final String pseudo;
  final NotificationBloc notificationBloc;

  const UpdateUserProfilEvent({
    required this.lastName,
    required this.firstName,
    required this.pseudo,
    required this.notificationBloc,
  });

  @override
  List<Object> get props => [lastName, firstName, pseudo];
}

class AuthUserChanged extends AuthEvent {
  final User? user;
  const AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user];
}
