import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/utils/logger.dart';

//receipte toke purchass: ohkoljchghofieoihkpeemih.AO-J1OzvURHUF0JQyXPdaJrW63neWApmXPcX7Jo08E6DbUheOEYsWXnCRnxnT1WiEQ4Ve7iUwajIINuG4IM_cePntGb1gb10RkHMxtB3k5gEapGvOP2DAnM



class SubscriptionService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _fireAuth = FirebaseAuth.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final Dio _dio = Dio();
  SubscriptionService() {
    _subscription = _iap.purchaseStream.listen(
          (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        // Handle error here.
        Logger.Red.log('Error in purchase stream: $error');
      },
    );
  }

  Future<void> init() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      print('In-App Purchases are not available');
      return;
    }
    await _iap.restorePurchases();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        // Extract the receipt data
        String receiptData = purchaseDetails.verificationData.serverVerificationData;
        Logger.Green.log('Receipt Data: $receiptData');

        // Validate the receipt with your backend
        validateSubscriptionWithBackend(receiptData);

        // Update subscription status in your backend
        updateSubscriptionStatus(true);
      }
    }
  }

  Future<bool> validateSubscriptionWithBackend(String receiptData) async {
    try {
      final response = await _dio.post(
        'https://your-backend-url.com/validate-subscription',
        data: {'receiptData': receiptData},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200) {
        Logger.Green.log('Validation de l\'abonnement réussie');
        final result = response.data;
        return result['isValid'];
      } else {
        Logger.Red.log('Erreur lors de la validation de l\'abonnement: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      Logger.Red.log('Exception lors de la communication avec le backend: $e');
      return false;
    }
  }

  Future<void> updateSubscriptionStatus(bool isSubscribed) async {
    try {
      await _firestore.collection('subscriptions').doc(_fireAuth.currentUser?.uid).set({
        'isSubscribed': isSubscribed,
        'subscriptionType': 'premium',
        'expiryDate': DateTime.now().add(Duration(days: 30)).toIso8601String(),
      });
      Logger.Green.log("Mise à jour de l'abonnement dans Firebase réussie");
    } catch (e) {
      Logger.Red.log('Exception lors de la mise à jour de l\'abonnement: $e');
    }
  }
}

