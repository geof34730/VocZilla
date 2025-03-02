import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/data_user_service.dart';
import 'data_user_repository.dart';

class AuthRepository {
  final AuthService _authService = AuthService();
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    UserCredential? userCredential = await _authService.signUpWithEmail(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    userCredential?.user?.updateDisplayName('$firstName $lastName');
    dataUserRepository.createUser(userCredential: userCredential);
    return userCredential?.user;
  }

  Future<User?> signInWithEmail({required String email, required String password}) async {
    UserCredential? userCredential = await _authService.signInWithEmail(email:email, password:password);
    dataUserRepository.createUser(userCredential: userCredential);
    return userCredential?.user;
  }

  Future<User> signInWithGoogle() async {
    UserCredential? userCredential= await _authService.signInWithGoogle();
    dataUserRepository.createUser(userCredential: userCredential);
    return userCredential!.user!;
  }

  Future<User> signInWithFacebook() async {
    UserCredential? userCredential= await _authService.signInWithFacebook();
    dataUserRepository.createUser(userCredential: userCredential);
    return userCredential!.user!;

  }

  Future<User> signInWithApple() async {
    UserCredential? userCredential=  await _authService.signInWithApple();
    dataUserRepository.createUser(userCredential: userCredential);
    return userCredential!.user!;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
