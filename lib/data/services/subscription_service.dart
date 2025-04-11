import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/utils/logger.dart';
import '../../logic/blocs/purchase/purchase_bloc.dart';

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
       

        // Update subscription status in your backend
        //updateSubscriptionStatus(true);
      }
    }
  }



  /*
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

   */
}

