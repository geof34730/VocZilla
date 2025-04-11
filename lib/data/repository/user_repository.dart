import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vobzilla/data/repository/auth_repository.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/ui.dart';
import '../../global.dart';
class UserRepository {
  final InAppPurchase inAppPurchase = InAppPurchase.instance;
  final Dio _dio = Dio();




  String? _purchaseToken;
  String? _platform;
  String? _subscriptionId;
  Completer<void> _purchaseCompleter = Completer<void>();

  Future<void> restorePurchases() async {
    print("restorePurchases");


    final bool available = await inAppPurchase.isAvailable();
    if (!available) {
      print("In-app purchases not available");
      return;
    }
    print("restorePurchases 2");
    // Cette méthode déclenche la récupération des achats précédents
    inAppPurchase.restorePurchases();
    print("restorePurchases 3");
    // Tu dois ensuite écouter le stream des achats
    inAppPurchase.purchaseStream.listen((List<PurchaseDetails> purchaseDetailsList) {
      print("restorePurchases 4");
      if(purchaseDetailsList.length==0){
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
  }

  Future<bool> checkSubscriptionStatus() async {
    // Vérifier le statut de l'abonnement
    Logger.Magenta.log("begin checkSubscriptionStatus");
    final prefAsync = await SharedPreferences.getInstance();
    var today = DateTime.now().toIso8601String().substring(0, 10);
    var lastShownDate = prefAsync.getString('lastFreeTrialDialogDate');

    Logger.Red.log("lastShownDate: $lastShownDate");
    Logger.Red.log("today: $today");
    if (lastShownDate == today) {
      Logger.Magenta.log("purchase already check today");
      Logger.Magenta.log("Last purchase check");



      print("lastCheckPurchase: ${prefAsync.getString('lastCheckPurchase')}");

      return prefAsync.getString('lastCheckPurchase') == "true" ? true : false;
      //return prefAsync.getString('lastCheckPurchase') as bool;
    }


    restorePurchases();
    await _purchaseCompleter.future;

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
          prefAsync.setString('lastCheckPurchase', data.toString());
          return data;
        } else {
          Logger.Red.log("Failed to verify subscription");
          throw Exception('Failed to verify subscription');
        }
    } catch (e) {
      Logger.Red.log("Error verifying subscription: $e");
      Logger.Red.log('Error verifying subscription: $e');
      prefAsync.setString('lastCheckPurchase', "false");
      return false;
   }




  }

  Future<DateTime?> getTrialEndDate() async {
    //retourne la date de fin de l'essai gratuit
    final endDate = await UserRepository().getDaysEndFreetrial();
    return endDate;
  }

  Future<int> getLeftDaysEndDate() async {
    //retourne le nombre de jour de l'essai gratuit
    return await UserRepository().getLeftDaysFreeTrial();
  }

  Future<DateTime?> getDaysEndFreetrial() async {
    DateTime? endDateFreeTrial;
    await AuthRepository().getUser().then((value) => endDateFreeTrial = value.metadata.creationTime?.add(Duration(days: daysFreeTrial)));
    return endDateFreeTrial;
  }

  Future<int> getLeftDaysFreeTrial() async {
    final now = DateTime.now();
    final endDate = await getDaysEndFreetrial();
    if (endDate == null) {
      return 0;
    }
    final difference = endDate.difference(now).inDays;
    return difference;
  }
}

final UserRepository userRepository = UserRepository();
