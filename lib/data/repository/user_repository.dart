import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vobzilla/data/repository/auth_repository.dart';

// AJOUT : Imports pour le modèle et le service de données Firestore
import 'package:vobzilla/data/models/user_firestore.dart';
import 'package:vobzilla/data/services/data_user_service.dart';

import '../../core/utils/logger.dart';
import '../../core/utils/ui.dart';
import '../../global.dart';
import '../../logic/blocs/user/user_bloc.dart';
import '../../logic/blocs/user/user_event.dart';
import '../../logic/blocs/user/user_state.dart';
import '../../ui/widget/elements/DialogHelper.dart';

class UserRepository {
  final InAppPurchase inAppPurchase = InAppPurchase.instance;
  final Dio _dio = Dio();
  // AJOUT : Instance du service pour communiquer avec Firestore
  final DataUserService _dataUserService = DataUserService();

  String? _purchaseToken;
  String? _platform;
  String? _subscriptionId;
  Completer<void> _purchaseCompleter = Completer<void>();
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  // AJOUT : Méthode pour sauvegarder un nouvel utilisateur dans Firestore
  /// Appelle le service de données pour sauvegarder un nouvel utilisateur.
  /// Retourne l'objet [UserFirestore] sauvegardé en cas de succès.
  Future<UserFirestore> saveNewUser(UserFirestore user) async {
    try {
      Logger.Green.log("UserRepository: Saving new user to Firestore...");
      // On délègue la sauvegarde au service et on retourne le résultat
      final savedUser = await _dataUserService.saveUserToFirestore(user: user);
      Logger.Green.log("UserRepository: User saved successfully.");
      return savedUser;
    } catch (e) {
      Logger.Red.log("UserRepository: Failed to save new user: $e");
      // On propage l'erreur pour que le BLoC puisse la gérer
      throw Exception("La création du profil utilisateur dans Firestore a échoué.");
    }
  }

  // AJOUT : Méthode pour mettre à jour un utilisateur dans Firestore
  /// Appelle le service de données pour mettre à jour un utilisateur.
  /// Retourne l'objet [UserFirestore] mis à jour en cas de succès.
  Future<UserFirestore> updateUserProfile(UserFirestore user) async {
    try {
      Logger.Green.log("UserRepository: Updating user profile in Firestore...");
      final updatedUser = await _dataUserService.updateUserToFirestore(user: user);
      Logger.Green.log("UserRepository: User profile updated successfully.");
      return updatedUser;
    } catch (e) {
      Logger.Red.log("UserRepository: Failed to update user profile: $e");
      throw Exception("La mise à jour du profil a échoué.");
    }
  }

  Future<void> checkUserStatusOncePerDay(BuildContext context) async {
    // GARDE D'AUTHENTIFICATION : Ne rien faire si aucun utilisateur n'est connecté.
    if (FirebaseAuth.instance.currentUser == null) {
      Logger.Yellow.log("checkUserStatusOncePerDay annulé : utilisateur non authentifié.");
      return;
    }

    Logger.Yellow.log("*********checkUserStatusOncePerDay");

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastCheckStatusDate = prefs.getString('lastCheckStatusDate');
    if (lastCheckStatusDate != today) {
      Logger.Green.log("checkUserStatusOncePerDay Checking user status");
      prefs.setString('lastCheckStatusDate', today);
      context.read<UserBloc>().add(CheckUserStatus());
    }
    else{
      Logger.Green.log("checkUserStatusOncePerDay Already checked today");
    }
  }

  Future<void> checkUserStatusForce() async {
    Logger.Green.log("checkUserStatusOncePerDayForce");
    final prefs = await SharedPreferences.getInstance();
    final yesterday = DateTime
        .now()
        .subtract(Duration(days: 5))
        .toIso8601String()
        .substring(0, 10);
    prefs.setString('lastCheckStatusDate', yesterday);
  }

  Future<void> showDialogueFreeTrialOnceByDay({required BuildContext context}) async {
    // GARDE D'AUTHENTIFICATION : Ne rien faire si aucun utilisateur n'est connecté.
    if (FirebaseAuth.instance.currentUser == null) {
      Logger.Yellow.log("showDialogueFreeTrialOnceByDay annulé : utilisateur non authentifié.");
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toIso8601String().substring(0, 10);
    String? lastShownDate = prefs.getString('lastFreeTrialDialogDate');
    if (lastShownDate != today) {
      // Mettre à jour la date dans SharedPreferences
      await prefs.setString('lastFreeTrialDialogDate', today);
      Logger.Green.log(
          "Check me status for UserFreeTrialPeriodAndNotSubscribed for free trial dialogue");
      final daysLeft = await getLeftDaysFreeTrial();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        DialogHelper().showFreeTrialDialog(context: context, daysLeft: daysLeft);
      });
    } else {
      Logger.Cyan.log("Le dialogue a déjà été affiché aujourd'hui");
    }
  }

  Future<void> restorePurchases() async {
    // Annuler toute souscription existante pour éviter les fuites avant d'en démarrer une nouvelle.
    await _purchaseSubscription?.cancel();
    print("restorePurchases");

    final bool available = await inAppPurchase.isAvailable();
    if (!available) {
      print("In-app purchases not available");
      if (!_purchaseCompleter.isCompleted) {
        _purchaseCompleter.complete();
      }
      return;
    }
    print("restorePurchases 2");
    // Écouter le stream d'achats pour obtenir les résultats de l'opération de restauration.
    _purchaseSubscription = inAppPurchase.purchaseStream.listen((List<PurchaseDetails> purchaseDetailsList) {
      print("restorePurchases 4");
      if (purchaseDetailsList.isEmpty) {
        if (!_purchaseCompleter.isCompleted) {
          _purchaseCompleter.complete();
        }
      }
      for (final purchase in purchaseDetailsList) {
        print("restorePurchases 5");
        if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
          Logger.Green.log('Produit: ${purchase.productID}');
          Logger.Green.log('Token: ${purchase.verificationData.serverVerificationData}');
          Logger.Green.log('Produit: ${purchase.verificationData.localVerificationData}');
          _purchaseToken =purchase.verificationData.serverVerificationData;
          _subscriptionId = purchase.productID;
          if (Platform.isAndroid) {
            _platform = 'android';
          } else if (Platform.isIOS) {
            _platform = 'ios';
          }
          if (!_purchaseCompleter.isCompleted) {
            _purchaseCompleter.complete();
          }
        }
      }
    });

    // Ceci déclenche la restauration. Les résultats seront livrés à l'écouteur ci-dessus.
    await inAppPurchase.restorePurchases();
    print("restorePurchases 3");
  }

  Future<bool> checkSubscriptionStatus() async {
    // Réinitialiser le completer pour cette nouvelle opération de vérification afin de s'assurer qu'il peut être attendu à nouveau.
    if (_purchaseCompleter.isCompleted) {
      _purchaseCompleter = Completer<void>();
    }

    // Vérifier le statut de l'abonnement
    Logger.Magenta.log("begin checkSubscriptionStatus");
    restorePurchases();
    await _purchaseCompleter.future;

    // Annuler l'écouteur de stream une fois l'opération terminée est crucial
    // pour éviter les fuites de mémoire et les comportements inattendus des anciens écouteurs.
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;

    if (_purchaseToken == null || _subscriptionId == null) {
      Logger.Red.log("No valid purchase details available");
      return false;
    }

    var suscriptionId = await getPackageName();
    Logger.Magenta.log("go checkSubscriptionStatus");
    Logger.Magenta.log('_purchaseToken: ${_purchaseToken}');
    Logger.Magenta.log('platform: ${_platform}');
    Logger.Magenta.log('subscriptionId: ${suscriptionId}');
    Logger.Magenta.log("Checking subscription status");
    try {
      Logger.Red.log("GO SERVICE");
      Logger.Yellow.log({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'purchaseToken': _purchaseToken,
        'platform': _platform,
        'subscriptionId': suscriptionId
      });
      final response = await _dio.post(
        serverSubcriptionStaturUrl,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'userId': FirebaseAuth.instance.currentUser?.uid,
          'purchaseToken': _purchaseToken,
          'platform': _platform,
          'subscriptionId': _subscriptionId
        },
      );
      if (response.statusCode == 200) {
        final data = response.data;
        Logger.Blue.log("isSubscribed: ${data}");
        return data;
      } else {
        Logger.Red.log("Failed to verify subscription");
        throw Exception('Failed to verify subscription');
      }
    } catch (e) {
      Logger.Red.log("Error verifying subscription: $e");
      Logger.Red.log('Error verifying subscription: $e');
      return false;
    }
  }

  Future<DateTime?> getTrialEndDate() async {
    //retourne la date de fin de l'essai gratuit
    final endDate = await getDaysEndFreetrial();
    return endDate;
  }

  Future<int> getLeftDaysEndDate() async {
    //retourne le nombre de jour de l'essai gratuit
    return await getLeftDaysFreeTrial();
  }

  Future<DateTime?> getDaysEndFreetrial() async {
    if (FirebaseAuth.instance.currentUser == null) {
      return null;
    }
    try {
      final user = await AuthRepository().getUserFirebase();
      if (user == null) {
        return null;
      }
      // creationTime peut aussi être null. L'opérateur ?. gère ce cas.
      return user.metadata.creationTime?.add(Duration(days: daysFreeTrial));
    } catch (e, s) {
      Logger.Red.log("Erreur lors de la récupération de l'utilisateur pour la date de fin d'essai : $e\nStackTrace: $s");
      return null;
    }
  }

  Future<int> getLeftDaysFreeTrial() async {
    final now = DateTime.now();
    final endDate = await getDaysEndFreetrial();
    if (endDate == null) {
      return 0;
    }
    final difference = endDate.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }
}

final UserRepository userRepository = UserRepository();
