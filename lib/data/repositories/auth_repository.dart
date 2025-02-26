// lib/data/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String language,
  }) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Update user profile
    await userCredential.user?.updateDisplayName('$firstName $lastName');
    // You can also store additional user information in Firestore or Realtime Database
    return userCredential.user;
  }

  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user;
  }



  Future<dynamic> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login(
      permissions : ['email', 'public_profile'],
    );



    FacebookAuth.instance.login(
      permissions : ['email', 'public_profile'],
    ).then((value)=> {

          print(value.accessToken)

        });



    print("LoginResult : $loginResult");
    print("loginResult.accessToken!.tokenString : ${loginResult.accessToken!.tokenString}");
    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential("EAAqRPLV9FeYBOzn3tWZAxOLZB4dAVxsvwVwQlkMebZAsjWsTUtQ7mOkXZB3F6m2nNN9ErFJdodw9RQpZBIAJfeFiOmISIzU4yCrIyQ5kZBbrsZCds3NczU0McuM5VrPVq2uREAO0Sn8xHIovY0qZBEGzD4ba6LZAMudDi4jJWKuPSnyJ2VUULqnY8jMHgkDFhFdvqEEWjgbZAOj3STRkxqJYaZBBMeRcHjn4Ke7xUGtMSkz0Gm6zTr63ak91gSusXwZD");
    print(facebookAuthCredential);
    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  /*
  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();
print("loginResult.accessToken!.tokenString : ${loginResult.accessToken!.tokenString}");
    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
print(facebookAuthCredential);
    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }
*/

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();

  }
}






