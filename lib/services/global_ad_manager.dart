import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/logic/blocs/user/user_bloc.dart';
import 'package:voczilla/logic/blocs/user/user_state.dart';
import 'package:voczilla/services/admob_service.dart';

class GlobalAdManager extends StatefulWidget {
  final Widget child;
  const GlobalAdManager({super.key, required this.child});

  @override
  State<GlobalAdManager> createState() => _GlobalAdManagerState();
}

class _GlobalAdManagerState extends State<GlobalAdManager> with WidgetsBindingObserver {
  Timer? _interstitialAdTimer;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initial check of subscription status
    final userState = context.read<UserBloc>().state;
    if (userState is UserSessionLoaded) {
      _isSubscribed = userState.isSubscribed;
    }
    _startTimerIfNeeded();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _interstitialAdTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _startTimerIfNeeded();
    } else {
      _stopInterstitialAdTimer();
    }
  }

  void _onSubscriptionChange(UserState state) {
    bool newIsSubscribed = false;
    if (state is UserSessionLoaded) {
      newIsSubscribed = state.isSubscribed;
    }

    if (_isSubscribed != newIsSubscribed) {
      _isSubscribed = newIsSubscribed;
      _startTimerIfNeeded();
    }
  }

  void _startTimerIfNeeded() {
    // Only start if not subscribed and app is resumed
    if (!_isSubscribed && WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      _startInterstitialAdTimer();
    } else {
      _stopInterstitialAdTimer();
    }
  }

  /// Démarre le minuteur pour les publicités.
  void _startInterstitialAdTimer() {
    // S'assure qu'un seul minuteur tourne à la fois.
    _interstitialAdTimer?.cancel();

    _interstitialAdTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      // On ne montre la pub que si l'app est au premier plan.
      if (!_isSubscribed && WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        AdMobService.instance.showInterstitialAd();
      }
    });
  }

  /// Arrête le minuteur.
  void _stopInterstitialAdTimer() {
    _interstitialAdTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        _onSubscriptionChange(state);
      },
      child: widget.child,
    );
  }
}
