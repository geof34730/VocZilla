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






  Future<void> signOut() async {
    await _authService.signOut();
  }
  /// Configure la persistance de la session utilisateur.
  Future<void> setPersistence() async {
    await _firebaseAuth.setPersistence(Persistence.LOCAL);
  }
}
