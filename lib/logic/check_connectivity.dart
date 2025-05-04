import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:vobzilla/ui/screens/offline_screen.dart';

class ConnectivityAwareWidget extends StatefulWidget {
  final Widget child;

  ConnectivityAwareWidget({required this.child});

  @override
  _ConnectivityAwareWidgetState createState() => _ConnectivityAwareWidgetState();
}

class _ConnectivityAwareWidgetState extends State<ConnectivityAwareWidget> {
  late Stream<List<ConnectivityResult>> _connectivityStream;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _connectivityStream = Connectivity().onConnectivityChanged;
    _connectivityStream.listen((List<ConnectivityResult> results) {
      setState(() {
        _isOffline =
            results.contains(ConnectivityResult.none) || results.isEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isOffline) {
      return OfflineScreen();
    }
    return widget.child;
  }
}



