import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:vobzilla/data/repository/user_repository.dart';
import '../../../core/utils/logger.dart';
import '../../../global.dart';
import 'purchase_event.dart';
import 'purchase_state.dart';

final idSubscriptionMensuel = 'mensuel_voczilla_076d28df';
final idSubscriptionAnnuel = 'annuel_voczilla_076d28df';

class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  PurchaseBloc() : super(PurchaseInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<BuyProduct>(_onBuyProduct);
    on<CheckActiveSubscriptions>(_onCheckActiveSubscriptions);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<PurchaseState> emit) async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      emit(PurchaseFailure('In-app purchases not available'));
      return;
    }
    Set<String> _kIds = {idSubscriptionMensuel,idSubscriptionAnnuel};
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_kIds);
    if (response.error != null) {
      emit(PurchaseFailure(response.error!.message));
      return;
    }
    emit(ProductsLoaded(response.productDetails));
  }

  Future<void> _onBuyProduct(BuyProduct event, Emitter<PurchaseState> emit) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: event.productDetails);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    // Vous pouvez écouter les mises à jour de l'achat pour gérer le succès ou l'échec
    Logger.Magenta.log('Achat en cours $purchaseParam');
  }

  Future<void> _onCheckActiveSubscriptions(CheckActiveSubscriptions event,
      Emitter<PurchaseState> emit) async {

    Logger.Green.log('GO activeSubscriptions');

    try {
      final purchases = await _inAppPurchase.purchaseStream.first;

      List<PurchaseDetails> activeSubscriptions = purchases.where((purchase) {
        return purchase.status == PurchaseStatus.purchased &&
            (purchase.productID == idSubscriptionMensuel ||
                purchase.productID == idSubscriptionAnnuel);
      }).toList();

      emit(SubscriptionsLoaded(activeSubscriptions));
    } catch (e) {
      Logger.Red.log('Failed to load active subscriptions: $e');
      emit(PurchaseFailure('Failed to load active subscriptions: $e'));
    }
  }
}


