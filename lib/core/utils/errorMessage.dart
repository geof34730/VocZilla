String errorFirebaseMessage(e) {
  String messageErreur = "erreur inconnue";
  switch (e.code) {
    case 'invalid-email':
      messageErreur="L'adresse e-mail est mal formée.";
      break;
    case 'user-disabled':
      messageErreur="Ce compte utilisateur a été désactivé.";
      break;
    case 'user-not-found':
      messageErreur="Aucun utilisateur trouvé avec cet e-mail.";
      break;
    case 'wrong-password':
      messageErreur="Le mot de passe est incorrect.";
      break;
    case 'email-already-in-use':
      messageErreur="L'adresse e-mail est déjà utilisée par un autre compte.";
      break;
    case 'operation-not-allowed':
      messageErreur="Cette opération n'est pas autorisée.";
      break;
    case 'weak-password':
      messageErreur="Le mot de passe est trop faible.";
      break;
    case 'account-exists-with-different-credential':
      messageErreur="Un compte existe déjà avec la même adresse e-mail mais avec des informations d'identification différentes. Connectez-vous en utilisant une méthode associée à ce compte.";
      break;
    case 'invalid-credential':
      messageErreur="Email ou mot de passe invalide.";
      break;
  }
  print("SignInRequested error=============> ${e.code} ${e.message}e" );
  return messageErreur;
}
