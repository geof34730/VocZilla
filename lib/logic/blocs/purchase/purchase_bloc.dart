import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../core/utils/logger.dart';
import '../../../global.dart'; // ← Assurez-vous que idSubscriptionMensuel et idSubscriptionAnnuel sont ici
import 'purchase_event.dart';
import 'purchase_state.dart';

class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late final StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;

  // On garde les produits pour pouvoir revenir à la liste sans les recharger.
  List<ProductDetails> _cachedProducts = const [];

  PurchaseBloc() : super(PurchaseInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<BuyProduct>(_onBuyProduct);
    on<CheckActiveSubscriptions>(_onCheckActiveSubscriptions); // Maintenant défini
    on<PurchaseFailed>(_onPurchaseFailed); // Maintenant défini
    on<PurchaseUpdated>(_onPurchaseUpdated);

    // Écoute du flux d’achats → on dispatch un event (pas de emit direct ici).
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen((list) => add(PurchaseUpdated(list)),
      onError: (error) {
        Logger.Red.log('Erreur flux achats: $error');
        add(PurchaseFailed(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _purchaseSubscription.cancel();
    return super.close();
  }

  // -------- Handlers --------

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<PurchaseState> emit) async {
    emit(PurchaseLoading()); // Bonnes pratiques : indiquer le chargement
    final available = await _inAppPurchase.isAvailable();
    if (!available) {
      emit(PurchaseFailure('In-app purchases not available'));
      return;
    }

    try {
      final ids = <String>{idSubscriptionMensuel, idSubscriptionAnnuel};
      final response = await _inAppPurchase.queryProductDetails(ids);

      if (response.error != null) {
        emit(PurchaseFailure(response.error!.message));
        return;
      }

      if (response.productDetails.isEmpty) {
        emit(PurchaseFailure('No products found. Check your product IDs.'));
        return;
      }

      _cachedProducts = response.productDetails;
      emit(ProductsLoaded(_cachedProducts));
    } catch (e) {
      emit(PurchaseFailure('Failed to load products: ${e.toString()}'));
    }
  }

  Future<void> _onBuyProduct(
      BuyProduct event, Emitter<PurchaseState> emit) async {
    if (_cachedProducts.isNotEmpty) {
      emit(PurchasingState(_cachedProducts));
    }

    try {
      final param = PurchaseParam(productDetails: event.productDetails);
      await _inAppPurchase.buyNonConsumable(purchaseParam: param);
      Logger.Magenta.log('Achat lancé: ${event.productDetails.id}');
    } on PlatformException catch (e) {
      final code = e.code;
      final msg = (e.message ?? '').toLowerCase();

      if (code == 'userCancelled' ||
          code == 'storekit2_purchase_cancelled' ||
          msg.contains('cancel')) {
        emit(ProductsLoaded(_cachedProducts));
        return;
      }

      emit(PurchaseFailure('${e.code}: ${e.message ?? 'Erreur achat'}'));
    } catch (e) {
      emit(PurchaseFailure(e.toString()));
    }
  }

  Future<void> _onPurchaseUpdated(
      PurchaseUpdated event, Emitter<PurchaseState> emit) async {
    var emittedTerminal = false;

    for (final p in event.details) {
      Logger.Blue.log('Update achat: ${p.productID} / ${p.status}');

      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          try {
            // TODO: vérification du reçu côté serveur recommandée ici
            Logger.Green.log('Achat validé/restauré pour ${p.productID}');
            emit(PurchaseCompleted());
            emittedTerminal = true;
          } catch (e) {
            emit(PurchaseFailure('Validation échouée: $e'));
            emittedTerminal = true;
          }
          break;

        case PurchaseStatus.error:
          Logger.Red.log('Erreur achat: ${p.error}');
          emit(PurchaseFailure(p.error?.message ?? 'Erreur StoreKit'));
          emittedTerminal = true;
          break;

        case PurchaseStatus.pending:
          break;

        case PurchaseStatus.canceled:
          Logger.Yellow.log('Achat annulé: ${p.productID}');
          emit(ProductsLoaded(_cachedProducts));
          emittedTerminal = true;
          break;
      }

      if (p.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(p);
      }
    }

    if (!emittedTerminal && state is PurchasingState) {
      emit(ProductsLoaded(_cachedProducts));
    }
  }

  // --- MÉTHODES MANQUANTES AJOUTÉES ---
  Future<void> _onCheckActiveSubscriptions(
      CheckActiveSubscriptions event, Emitter<PurchaseState> emit) async {
    // Logique pour vérifier les abonnements actifs au démarrage de l'app
    // Par exemple, en restaurant les achats
    await _inAppPurchase.restorePurchases();
    Logger.Blue.log("Vérification des abonnements actifs (restauration)...");
  }

  void _onPurchaseFailed(PurchaseFailed event, Emitter<PurchaseState> emit) {
    // Gérer l'échec globalement si nécessaire
    emit(PurchaseFailure(event.error));
  }
} // <-- Accolade de classe manquante
