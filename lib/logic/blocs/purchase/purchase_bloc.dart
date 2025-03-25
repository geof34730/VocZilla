import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'purchase_event.dart';
import 'purchase_state.dart';

class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  PurchaseBloc() : super(PurchaseInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<BuyProduct>(_onBuyProduct);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<PurchaseState> emit) async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      emit(PurchaseFailure('In-app purchases not available'));
      return;
    }

    const Set<String> _kIds = {'mensuel','annuel'};
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_kIds);
    if (response.error != null) {
      emit(PurchaseFailure(response.error!.message));
      return;
    }

   final  myResponse = response;
    print("response: $response");

    for (ProductDetails product in response.productDetails) {
     // if (product.id == 'annuel') {
        // Affichez les détails du produit
        print('Produit mensuel: ${product.title}, ${product.description}');
        // Vérifiez les informations disponibles sur le produit
        print('Prix: ${product.price}');
        print('Description: ${product.description}');
        print('product.currencySymbol: ${product.currencySymbol}');
        print('product.currencyCode: ${product.currencyCode}');
        print('product.id: ${product.id}');
        print('product.rawPrice: ${product.rawPrice}');
       // print('product.subscriptionOfferDetails: ${product.subscriptionOfferDetails}');
        // Vous pouvez également vérifier d'autres propriétés comme `product.introductoryPricePeriod` si disponible
     // }
    }

    emit(ProductsLoaded(response.productDetails));
  }

  Future<void> _onBuyProduct(BuyProduct event, Emitter<PurchaseState> emit) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: event.productDetails);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    // Vous pouvez écouter les mises à jour de l'achat pour gérer le succès ou l'échec
  }
}
