import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/logic/blocs/auth/auth_bloc.dart';
import 'package:vobzilla/logic/blocs/auth/auth_event.dart';
import '../../../core/utils/errorMessage.dart';
import '../../../core/utils/getFontForLanguage.dart';
import '../../../core/utils/logger.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../backgroundBlueLinear.dart';

// --- NOUVEAUX IMPORTS ---
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

// Import pour votre widget d'erreur personnalisé
import '../../widget/elements/Error.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  static const _storage = FlutterSecureStorage();
  static const _kPersistentUidKey = 'persistent_uid';
  static const _iOpts = IOSOptions(accessibility: KeychainAccessibility.first_unlock);
  static const _mOpts = MacOsOptions();
  static const _aOpts = AndroidOptions(encryptedSharedPreferences: true);


  /// Retourne un UID persistant (généré une seule fois puis stocké).
  Future<String> _getOrCreatePersistentUid() async {
    String? uid = await _storage.read(key: _kPersistentUidKey, iOptions: _iOpts, aOptions: _aOpts, mOptions: _mOpts);
    if (uid == null || uid.isEmpty) {
      uid = const Uuid().v4(); // ex: "e2e1d2d8-..."
      await _storage.write(key: _kPersistentUidKey, value: uid, iOptions: _iOpts, aOptions: _aOpts, mOptions: _mOpts);
    }
    return uid;
  }

  /// Gère l'authentification en tant qu'invité et notifie le BLoC.
  Future<void> _signInAsGuest() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // 1) Lire/créer l’UID persistant local
      final String myUid = await _getOrCreatePersistentUid();
      Logger.Green.log('UID persistant = $myUid');

      // 2) Appeler la Cloud Function pour obtenir un custom token pour *cet* UID
      final callable = FirebaseFunctions.instance.httpsCallable('signInWithUid');

      final parameters = <String, dynamic>{'uid': myUid};
      final res = await callable.call(parameters);

      final String token = (res.data as Map)['customToken'] as String;

      // 3) Se connecter à Firebase avec ce token => user.uid == myUid
      final UserCredential cred =
      await FirebaseAuth.instance.signInWithCustomToken(token);
      final user = cred.user;
      if (user == null) {
        throw Exception(
            "Firebase a renvoyé un user null après signInWithCustomToken");
      }
      debugPrint('Connexion OK avec UID persistant = ${user.uid}');
      if (mounted) {
        context.read<AuthBloc>().add(AuthLoggedIn(user));
        Navigator.pop(context);

      }
    } on FirebaseFunctionsException catch (e) {
      // Capter spécifiquement les erreurs de Cloud Functions pour un meilleur debug
      debugPrint('Erreur Cloud Function [${e.code}]: ${e.message}');
      debugPrint('Détails: ${e.details}');
      debugPrint(e.stackTrace.toString());
      if (mounted) {
        // Utilisation de votre système d'erreur localisé
        final message = getLocalizedErrorMessage(context, '[firebase_auth/${e.code}] ${e.message}');
        ErrorMessage(context: context, message: message);
      }
    } catch (e, s) {
      // Capter toutes les autres erreurs
      debugPrint('Erreur auth: $e\n$s');
      if (mounted) {
        // Utilisation de votre système d'erreur localisé
        final message = getLocalizedErrorMessage(context, e.toString());
        ErrorMessage(context: context, message: message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final codelang = Localizations.localeOf(context).languageCode;
    return BackgroundBlueLinear(
      child: Center(
        child: Padding(
          key: const ValueKey('login_screen'),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20), // Un peu plus d'espace
                child: Text(
                  context.loc.login_se_connecter,
                  style: getFontForLanguage(codelang: codelang, fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: _signInAsGuest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : Text(
                  "Entrer en tant qu'invité",
                  style: getFontForLanguage(codelang: codelang, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
