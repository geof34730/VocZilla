import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'logger.dart';

String getLocalizedErrorMessage(BuildContext context, String inputError) {
  final l10n = AppLocalizations.of(context)!;
  String keyToTranslate = inputError;
  final regExp = RegExp(r'\[firebase_auth\/([^\]]+)\]');
  final match = regExp.firstMatch(inputError);
  if (match != null) {
    keyToTranslate = match.group(1)!;
    Logger.Green.log("Firebase error code extracted: $keyToTranslate");
  } else {
    Logger.Yellow.log("Input is not a Firebase error string, using as is: $keyToTranslate");
  }
  return switch (keyToTranslate) {
    'invalid-email' => l10n.firebase_error_message_invalid_email,
    'user-disabled' => l10n.firebase_error_message_user_disabled,
    'invalid-credential' => l10n.firebase_error_message_invalid_credential,
    'wrong-password' => l10n.firebase_error_message_invalid_credential,
    'user-not-found' => l10n.firebase_error_message_invalid_credential,
    'email-already-in-use' => l10n.firebase_error_message_email_already_in_use,
    'operation-not-allowed' => l10n.firebase_error_message_operation_not_allowed,
    'weak-password' => l10n.firebase_error_message_weak_password,
    'account-exists-with-different-credential' => l10n.firebase_error_message_account_exists_with_different_credential,
    'too-many-requests' => l10n.firebase_error_message_too_many_requests,
    'auth-error-deconnect' => l10n.auth_error_deconnect,
    'auth_error_register_unknown' => l10n.auth_error_register_unknown,
    'auth_error_create_user' => l10n.auth_error_create_user,
    'auth_error_connect' => l10n.auth_error_connect,
    'auth_error_update_profil' => l10n.auth_error_update_profil,
    'auth_error_google' => l10n.auth_error_google,
    'auth_error_facebook' => l10n.auth_error_facebook,
    'auth_error_apple' => l10n.auth_error_apple,
    'auth_error_echoue' => l10n.auth_error_echoue,
    'auth_success_update_profile' => l10n.auth_success_update_profile,
    'vocabulaire_user_error_delete_list' => l10n.vocabulaire_user_error_delete_list,
    'vocabulaire_user_error_delete_vocabulaire_list' => l10n.vocabulaire_user_error_delete_vocabulaire_list,
    'vocabulaire_user_error_user_data_not_found' => l10n.vocabulaire_user_error_user_data_not_found,
    'vocabulaire_user_error_add_list_perso' => l10n.vocabulaire_user_error_add_list_perso,
    'vocabulaire_user_error_update_list_perso' => l10n.vocabulaire_user_error_update_list_perso,
    'vocabulaire_user_error_add_vocabulaire_list_perso' => l10n.vocabulaire_user_error_add_vocabulaire_list_perso,



    _ => l10n.firebase_error_message_error_generic,
  };
}

String getLocalizedSuccessMessage(BuildContext context, String inputError) {
  final l10n = AppLocalizations.of(context)!;
  String keyToTranslate = inputError;
  final regExp = RegExp(r'\[SuccessBloc\/([^\]]+)\]');
  final match = regExp.firstMatch(inputError);

  if (match != null) {
    keyToTranslate = match.group(1)!;
    Logger.Green.log("Firebase error code extracted: $keyToTranslate");
  } else {
    Logger.Yellow.log("Input is not a Firebase error string, using as is: $keyToTranslate");
  }
  return switch (keyToTranslate) {
    'auth_success_update_profile' => l10n.auth_success_update_profile,
    'vocabulaire_success_delete_list' => l10n.vocabulaire_success_delete_list,

    _ => 'success action',
  };
}

