// lib/logic/blocs/auth/auth_event.dart
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../notification/notification_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class AuthLoggedIn extends AuthEvent {
  final User user;

  const AuthLoggedIn(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();
}

class SignOutRequested extends AuthEvent {}

class AuthErrorCleared extends AuthEvent {}

class AuthSuccessCleared extends AuthEvent {}

class UpdateUserEvent extends AuthEvent {
  final User user;
  const UpdateUserEvent(this.user);
  @override
  List<Object> get props => [user];
}

class UpdateUserProfilEvent extends AuthEvent {
  final String pseudo;
  final String? imageAvatar;

  const UpdateUserProfilEvent({
    required this.pseudo,
    this.imageAvatar,
  });

  @override
  // Add imageAvatar to the props list for correct equality checks.
  List<Object?> get props => [pseudo, imageAvatar];
}


