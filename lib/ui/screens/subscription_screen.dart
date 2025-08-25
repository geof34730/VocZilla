import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:vobzilla/core/utils/localization.dart';
import '../../core/utils/getFontForLanguage.dart';
import '../../global.dart';
import '../../logic/blocs/purchase/purchase_bloc.dart';
import '../../logic/blocs/purchase/purchase_event.dart';
import '../../logic/blocs/purchase/purchase_state.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> with WidgetsBindingObserver {
  /// ID du produit dont le bouton affiche le loader (null = aucun).
  String? _purchasingProductId;

  /// Écoute locale du flux d’achats pour capter canceled/error.
  StreamSubscription<List<PurchaseDetails>>? _purchaseStreamSub;

  /// Indique qu’on attend le retour de la feuille de paiement.
  bool _awaitingSheetClose = false;

  /// Timer pour “débloquer” le loader au retour d’arrière-plan si aucun event n’est reçu.
  Timer? _resumeSafetyTimer;

  @override
  void initState() {
    super.initState();

    // Observe le cycle de vie (utile quand la feuille se ferme sans event).
    WidgetsBinding.instance.addObserver(this);

    // Charge la liste des produits via le BLoC.
    context.read<PurchaseBloc>().add(const LoadProducts());

    // Écoute le flux d’achats (certains stores envoient canceled/error, d’autres non).
    _purchaseStreamSub = InAppPurchase.instance.purchaseStream.listen(
          (List<PurchaseDetails> purchases) {
        // S'il y a un event, on n’attend plus la feuille.
        _awaitingSheetClose = false;

        for (final p in purchases) {
          switch (p.status) {
            case PurchaseStatus.canceled:
            case PurchaseStatus.error:
            // L’utilisateur a fermé la feuille ou une erreur est survenue → stop loader.
              if (mounted) setState(() => _purchasingProductId = null);
              break;
            case PurchaseStatus.purchased:
            case PurchaseStatus.restored:
            // Le succès est géré par le BLoC (PurchaseCompleted).
              break;
            case PurchaseStatus.pending:
            // On garde le loader tant que c’est pending.
              break;
          }
        }
      },
      onError: (_) {
        // En cas d’erreur de stream, on enlève le loader pour éviter un blocage visuel.
        if (mounted) setState(() => _purchasingProductId = null);
        _awaitingSheetClose = false;
      },
    );
  }

  @override
  void dispose() {
    _purchaseStreamSub?.cancel();
    _resumeSafetyTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _purchasingProductId = null;
    _awaitingSheetClose = false;
    super.dispose();
  }

  /// Cycle de vie : quand on revient en `resumed`, si la feuille a été fermée
  /// sans event (cas Android fréquent), on arrête le loader après une petite latence.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingSheetClose) {
      // On attend un court instant pour laisser une chance à un event d’arriver.
      _resumeSafetyTimer?.cancel();
      _resumeSafetyTimer = Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        // Si on attendait toujours et qu’aucun event n’est venu → on coupe le loader.
        setState(() {
          _purchasingProductId = null;
          _awaitingSheetClose = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final endTrial = args != null && args['endTrial'] == true;

    return BlocListener<PurchaseBloc, PurchaseState>(
      listener: (context, state) {
        if (state is PurchaseCompleted) {
          // Achat réussi -> on enlève le loader local et on ferme l'écran.
          setState(() => _purchasingProductId = null);
          Navigator.of(context).pop(true);
        } else if (state is PurchaseFailure) {
          // Achat échoué (store a renvoyé une erreur au BLoC) -> enlève le loader.
          setState(() => _purchasingProductId = null);

          // Optionnel : feedback utilisateur.
          final msg = state.error.isNotEmpty
              ? '${context.loc.erreur_chargement_produits}\n\n"${state.error}"'
              : context.loc.erreur_chargement_produits;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
      },
      child: Column(
        key:const ValueKey('screenSubscription'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (endTrial)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 15, left: 8, right: 8),
                child: Text(
                  context.loc.freetrial_info1.replaceAll("\$daysFreeTrial", "$daysFreeTrial"),
                  style: const TextStyle(
                    height:1.1,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
              child: Text(
                context.loc.freetrial_info2,
                style: const TextStyle(
                  height:1.1,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          BlocBuilder<PurchaseBloc, PurchaseState>(
            builder: (context, state) {
              // 1) Chargement / initial
              if (state is PurchaseLoading || state is PurchaseInitial) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // 2) Échec avec option de réessayer (chargement de produits)
              if (state is PurchaseFailure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${context.loc.erreur_chargement_produits}\n\n"${state.error}"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            context.read<PurchaseBloc>().add(const LoadProducts());
                          },
                          child: Text(context.loc.reessayer),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 3) Succès : liste des produits
              if (state is ProductsLoaded) {
                final sortedProducts = List<ProductDetails>.from(state.products)
                  ..sort((a, b) => a.price.compareTo(b.price));

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 15, left: 8, right: 8),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedProducts.length,
                  itemBuilder: (context, index) {
                    final product = sortedProducts[index];
                    final isMensuel = product.id == idSubscriptionMensuel;

                    // Loader uniquement pour le produit cliqué.
                    final isThisPurchasing = _purchasingProductId == product.id;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    isMensuel ? context.loc.abonnement_mensuel : context.loc.abonnement_annuel,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${product.price}/${isMensuel ? context.loc.mois : context.loc.annee}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Center(
                                child: Text(
                                  isMensuel
                                      ? context.loc.abonnement_descriptif_mensuel
                                      : context.loc.abonnement_descriptif_annuel,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                ),
                                onPressed: () {
                                  // Active le loader uniquement sur CE bouton.
                                  setState(() {
                                    _purchasingProductId = product.id;
                                    _awaitingSheetClose = true; // on attend le retour de la feuille
                                  });
                                  context.read<PurchaseBloc>().add(BuyProduct(product));
                                },
                                child: isThisPurchasing
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                                    : Text(context.loc.button_sabonner),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              // Fallback
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
