import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/logic/blocs/purchase/purchase_is_subscribed_bloc.dart';
import 'package:voczilla/services/admob_service.dart';

class GlobalAdManager extends StatefulWidget {
  final Widget child;
  const GlobalAdManager({super.key, required this.child});

  @override
  State<GlobalAdManager> createState() => _GlobalAdManagerState();
}

class _GlobalAdManagerState extends State<GlobalAdManager> with WidgetsBindingObserver {
  Timer? _interstitialAdTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Vérification initiale après le premier rendu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTimerBasedOnState(context.read<PurchaseIsSubscribedBloc>().state);
    });
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
    // Réévalue le minuteur à chaque changement de cycle de vie de l'application
    _updateTimerBasedOnState(context.read<PurchaseIsSubscribedBloc>().state);
  }

  void _updateTimerBasedOnState(PurchaseIsSubscribedState state) {
    final isSubscribed = state.isSubscribed;
    final appIsResumed = WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

    // Le minuteur ne doit tourner que si l'on sait que l'utilisateur n'est PAS abonné
    // et que l'application est au premier plan.
    if (isSubscribed == false && appIsResumed) {
      _startInterstitialAdTimer();
    } else {
      // Dans tous les autres cas (abonné, statut inconnu, ou app en arrière-plan),
      // on arrête le minuteur.
      _stopInterstitialAdTimer();
    }
  }

  /// Démarre le minuteur pour les publicités interstitielles.
  void _startInterstitialAdTimer() {
    // Si un minuteur est déjà actif, on ne fait rien.
    if (_interstitialAdTimer?.isActive ?? false) return;

    _interstitialAdTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      // La décision de démarrer le minuteur a déjà confirmé que l'utilisateur n'est pas abonné
      // et que l'app est au premier plan. On peut donc montrer la pub directement.
      AdMobService.instance.showInterstitialAd();
    });
  }

  /// Arrête le minuteur.
  void _stopInterstitialAdTimer() {
    _interstitialAdTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PurchaseIsSubscribedBloc, PurchaseIsSubscribedState>(
      // Le listener met à jour le minuteur à chaque changement de statut d'abonnement.
      listener: (context, state) {
        _updateTimerBasedOnState(state);
      },
      child: widget.child,
    );
  }
}
