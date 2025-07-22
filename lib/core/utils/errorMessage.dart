import 'package:firebase_auth/firebase_auth.dart';
import 'logger.dart';

String errorFirebaseMessage(FirebaseAuthException e) {
  Logger.Red.log("Firebase Auth Error => Code: ${e.code}, Message: ${e.message}");
  return switch (e.code) {
    'invalid-email' => "L'adresse e-mail est mal formée.",
    'user-disabled' => "Ce compte utilisateur a été désactivé.",
    'user-not-found' || 'wrong-password' || 'invalid-credential' => "L'e-mail ou le mot de passe est incorrect.",
    'email-already-in-use' => "L'adresse e-mail est déjà utilisée par un autre compte.",
    'operation-not-allowed' => "Cette opération n'est pas autorisée.",
    'weak-password' => "Le mot de passe est trop faible.",
    'account-exists-with-different-credential' => "Un compte existe déjà avec la même adresse e-mail mais avec des informations d'identification différentes.",
    'too-many-requests' => "Trop de tentatives. Veuillez réessayer plus tard.", // Ajout d'un cas commun

  // Cas par défaut amélioré pour toutes les autres erreurs (ex: problème réseau).
    _ => "Une erreur inattendue est survenue. Veuillez réessayer.",
  };
}
