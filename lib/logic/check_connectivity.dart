import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:voczilla/ui/screens/offline_screen.dart';
import 'dart:async'; // Ajoute ceci pour StreamSubscription

class ConnectivityAwareWidget extends StatefulWidget {
  final Widget child;

  ConnectivityAwareWidget({required this.child});

  @override
  _ConnectivityAwareWidgetState createState() => _ConnectivityAwareWidgetState();
}

class _ConnectivityAwareWidgetState extends State<ConnectivityAwareWidget> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    // On écoute le stream et on garde la référence à l'abonnement
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (!mounted) return; // Sécurité : on vérifie que le widget est encore monté
      setState(() {
        _isOffline =
            results.contains(ConnectivityResult.none) || results.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    // On annule l'abonnement pour éviter les appels après dispose
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isOffline) {
      return OfflineScreen();
    }
    return widget.child;
  }
}
