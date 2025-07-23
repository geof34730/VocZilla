import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vobzilla/core/utils/ui.dart';

import '../../core/utils/logger.dart';
import '../../global.dart';
import '../../logic/blocs/user/user_bloc.dart';
import '../../logic/blocs/user/user_event.dart';
import '../../ui/widget/elements/DialogHelper.dart';


class UserRepository {

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final Dio _dio = Dio();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _purchaseToken;
  String? _platform;
  String? _subscriptionId;
  Completer<void> _purchaseCompleter = Completer<void>();
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .get();
    if (doc.exists) {
      return doc.data()!;
    } else {
      throw Exception("User not found");
    }
  }


  Future<void> checkUserStatusOncePerDay(BuildContext context) async {
    // AUTHENTICATION GUARD: Do nothing if no user is signed in.
    if (_firebaseAuth.currentUser == null) {
      Logger.Yellow.log("checkUserStatusOncePerDay cancelled: user not authenticated.");
      return;
    }

    Logger.Yellow.log("*********checkUserStatusOncePerDay");

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastCheckStatusDate = prefs.getString('lastCheckStatusDate');

    if (lastCheckStatusDate != today) {
      Logger.Green.log("checkUserStatusOncePerDay: Checking user status...");
      prefs.setString('lastCheckStatusDate', today);
      // It's safer to check if the context is still mounted before using it.
      if (context.mounted) {
        context.read<UserBloc>().add(CheckUserStatus());
      }
    } else {
      Logger.Green.log("checkUserStatusOncePerDay: Already checked today.");
    }
  }

  Future<void> checkUserStatusForce() async {
    Logger.Green.log("checkUserStatusForce triggered.");
    final prefs = await SharedPreferences.getInstance();
    // Forcing a check by setting the last check date to the past.
    final yesterday =
    DateTime.now().subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
    await prefs.setString('lastCheckStatusDate', yesterday);
  }

  Future<void> showDialogueFreeTrialOnceByDay(
      {required BuildContext context}) async {
    // AUTHENTICATION GUARD: Do nothing if no user is signed in.
    if (_firebaseAuth.currentUser == null) {
      Logger.Yellow.log("showDialogueFreeTrialOnceByDay cancelled: user not authenticated.");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastShownDate = prefs.getString('lastFreeTrialDialogDate');

    if (lastShownDate != today) {
      await prefs.setString('lastFreeTrialDialogDate', today);
      Logger.Green.log("Showing free trial dialog for UserFreeTrialPeriodAndNotSubscribed.");
      final daysLeft = await getLeftDaysFreeTrial();
      // Ensure the widget is built before showing a dialog.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          DialogHelper().showFreeTrialDialog(context: context, daysLeft: daysLeft);
        }
      });
    } else {
      Logger.Cyan.log("Free trial dialog already shown today.");
    }
  }

  Future<void> restorePurchases() async {
    // Cancel any existing subscription to avoid leaks before starting a new one.
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;

    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      print("In-app purchases not available");
      if (!_purchaseCompleter.isCompleted) _purchaseCompleter.complete();
      return;
    }

    // Listen to the purchase stream to get results from the restore operation.
    _purchaseSubscription =
        _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
          if (purchaseDetailsList.isEmpty && !_purchaseCompleter.isCompleted) {
            _purchaseCompleter.complete();
            return;
          }
          for (final purchase in purchaseDetailsList) {
            if (purchase.status == PurchaseStatus.purchased ||
                purchase.status == PurchaseStatus.restored) {
              Logger.Green.log('Product restored: ${purchase.productID}');
              _purchaseToken = purchase.verificationData.serverVerificationData;
              _subscriptionId = purchase.productID;
              _platform = Platform.isAndroid ? 'android' : 'ios';

              if (!_purchaseCompleter.isCompleted) {
                _purchaseCompleter.complete();
              }
              // We found a valid purchase, no need to process further in this loop.
              break;
            }
          }
        }, onDone: () {
          if (!_purchaseCompleter.isCompleted) _purchaseCompleter.complete();
        }, onError: (error) {
          if (!_purchaseCompleter.isCompleted) _purchaseCompleter.completeError(error);
        });

    // This triggers the restore. Results will be delivered to the listener above.
    await _inAppPurchase.restorePurchases();
  }

  Future<bool> checkSubscriptionStatus() async {
    // Reset the completer for this new check operation.
    if (_purchaseCompleter.isCompleted) {
      _purchaseCompleter = Completer<void>();
    }

    Logger.Magenta.log("Beginning checkSubscriptionStatus...");
    try {
      await restorePurchases();
      await _purchaseCompleter.future;
    } catch (e) {
      Logger.Red.log("Error during restorePurchases: $e");
    } finally {
      // It's crucial to cancel the stream listener once the operation is complete
      // to prevent memory leaks and unexpected behavior from old listeners.
      await _purchaseSubscription?.cancel();
      _purchaseSubscription = null;
    }


    if (_purchaseToken == null || _subscriptionId == null) {
      Logger.Red.log("No valid purchase details available after restore.");
      return false;
    }

    Logger.Magenta.log("Verifying subscription with backend...");
    try {
      final response = await _dio.post(
        serverSubcriptionStaturUrl,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'userId': _firebaseAuth.currentUser?.uid,
          'purchaseToken': _purchaseToken,
          'platform': _platform,
          'subscriptionId': _subscriptionId
        },
      );

      if (response.statusCode == 200 && response.data is bool) {
        Logger.Blue.log("Subscription status from backend: ${response.data}");
        return response.data;
      } else {
        Logger.Red.log("Failed to verify subscription. Status: ${response.statusCode}, Body: ${response.data}");
        return false;
      }
    } catch (e) {
      Logger.Red.log("Error verifying subscription with backend: $e");
      return false;
    }
  }

  Future<DateTime?> getTrialEndDate() async {
    return await _getDaysEndFreetrial();
  }

  Future<int> getLeftDaysEndDate() async {
    return await getLeftDaysFreeTrial();
  }

  Future<DateTime?> _getDaysEndFreetrial() async {
    // The user object from FirebaseAuth contains the metadata.
    final user = _firebaseAuth.currentUser;
    // creationTime can also be null. The ?. operator handles this case.
    return user?.metadata.creationTime?.add(Duration(days: daysFreeTrial));
  }

  Future<int> getLeftDaysFreeTrial() async {
    final now = DateTime.now();
    final endDate = await _getDaysEndFreetrial();
    if (endDate == null) {
      return 0;
    }
    final difference = endDate.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }
}

/// A global instance for easy access, following the service locator pattern.
final UserRepository userRepository = UserRepository();
