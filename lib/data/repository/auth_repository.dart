// lib/data/repository/auth_repository.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Le AuthRepository est maintenant uniquement responsable de la communication
/// avec le service d'authentification Firebase. Il ne gère plus la création
/// de la base de données utilisateur.
class AuthRepository {
  final AuthService _authService = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Retourne l'utilisateur Firebase actuellement connecté.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Inscrit un utilisateur avec email/mot de passe et retourne le UserCredential.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String pseudo,
  }) async {
    return await _authService.signUpWithEmail(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      pseudo: pseudo,
    );
  }

  /// Connecte un utilisateur avec email/mot de passe et retourne le UserCredential.
  Future<UserCredential> signInWithEmail(
      {required String email, required String password}) async {
    return await _authService.signInWithEmail(email: email, password: password);
  }

  /// Connecte un utilisateur avec Google et retourne le UserCredential.
  Future<UserCredential> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  /// Connecte un utilisateur avec Facebook et retourne le UserCredential.
  Future<UserCredential> signInWithFacebook() async {
    return await _authService.signInWithFacebook();
  }

  /// Connecte un utilisateur avec Apple et retourne le UserCredential.
  Future<UserCredential> signInWithApple() async {
    return await _authService.signInWithApple();
  }

  /// Déconnecte l'utilisateur.
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Configure la persistance de la session utilisateur.
  Future<void> setPersistence() async {
    await _firebaseAuth.setPersistence(Persistence.LOCAL);
  }
}
