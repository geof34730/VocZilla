import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/logic/blocs/purchase/purchase_is_subscribed_bloc.dart';
import 'package:voczilla/services/admob_service.dart';
import 'package:voczilla/ui/widget/elements/DialogHelper.dart';
import '../core/utils/navigatorKey.dart'; // Import de la clé globale

class GlobalAdManager extends StatefulWidget {
  final Widget child;
  const GlobalAdManager({super.key, required this.child});

  @override
  State<GlobalAdManager> createState() => _GlobalAdManagerState();
}

class _GlobalAdManagerState extends State<GlobalAdManager> with WidgetsBindingObserver {
  // Minuteur pour les publicités interstitielles
  Timer? _interstitialAdTimer;
  // Minuteur pour la boîte de dialogue d'abonnement
  Timer? _subscriptionDialogTimer;

  // Statut d'abonnement unifié : null = inconnu, true = abonné, false = non abonné
  bool? _isSubscribed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopAllTimers();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Si l'utilisateur n'est pas abonné, on redémarre le minuteur de pub interstitielle
      if (_isSubscribed == false) {
        _startInterstitialAdTimer();
      }
    } else {
      // Si l'application passe en arrière-plan, on arrête tout pour économiser les ressources
      _stopAllTimers();
    }
  }

  void _stopAllTimers() {
    _interstitialAdTimer?.cancel();
    _subscriptionDialogTimer?.cancel();
  }

  /// Démarre le minuteur pour les publicités INTERSTITIELLES.
  void _startInterstitialAdTimer() {
    _interstitialAdTimer?.cancel();
    _interstitialAdTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_isSubscribed == false && WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        AdMobService.instance.showInterstitialAd();
      }
    });
  }

  /// Affiche la boîte de dialogue d'ABONNEMENT et planifie la suivante.
  void _showSubscriptionBannerAndScheduleNext() {
    // Annule le minuteur précédent, car on va afficher la boîte de dialogue maintenant.
    _subscriptionDialogTimer?.cancel();

    // Utilise la clé globale pour obtenir un contexte valide depuis l'intérieur de MaterialApp
    final context = navigatorKey.currentContext;

    // Vérifie si l'utilisateur est toujours non abonné et si le contexte est valide
    if (_isSubscribed == false && context != null) {
      // showDialog renvoie un Future qui se termine lorsque la boîte de dialogue est fermée.
      DialogHelper().showSubscriptionBanner(context: context).then((_) {
        // Une fois la boîte de dialogue fermée, on planifie la prochaine dans 5 minutes.
        if (_isSubscribed == false && WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
          _subscriptionDialogTimer = Timer(const Duration(minutes: 5), () {
            _showSubscriptionBannerAndScheduleNext(); // Appel récursif pour la boucle
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // On écoute la source unique de vérité pour le statut de l'abonnement.
    return BlocListener<PurchaseIsSubscribedBloc, PurchaseIsSubscribedState>(
      listener: (context, state) {
        final newIsSubscribed = state.isSubscribed;

        // On ne fait rien tant que le statut n'est pas définitivement connu (pas null)
        if (newIsSubscribed == null) {
          return;
        }

        // Si le statut a changé...
        if (_isSubscribed != newIsSubscribed) {
          _isSubscribed = newIsSubscribed;

          if (_isSubscribed == false) {
            // L'utilisateur est confirmé comme NON abonné.
            _startInterstitialAdTimer();

            // On affiche la boîte de dialogue pour la première fois.
            // addPostFrameCallback garantit que cela s'exécute après la construction de l'UI,
            // ce qui rend navigatorKey disponible et évite les erreurs.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showSubscriptionBannerAndScheduleNext();
            });
          } else {
            // L'utilisateur EST abonné. On arrête tous les minuteurs liés aux pubs.
            _stopAllTimers();
          }
        }
      },
      child: widget.child,
    );
  }
}
