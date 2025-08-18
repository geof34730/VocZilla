import 'package:in_app_purchase/in_app_purchase.dart';

abstract class PurchaseState {}

class PurchaseInitial extends PurchaseState {}

// --- ADD THIS CLASS ---
class PurchaseLoading extends PurchaseState {}
// --------------------

class ProductsLoaded extends PurchaseState {
  final List<ProductDetails> products;
  ProductsLoaded(this.products);
}

/// Nouvel état : achat en cours → pour désactiver l’UI/spinner
class PurchasingState extends ProductsLoaded {
  PurchasingState(List<ProductDetails> products) : super(products);
}

class PurchaseSuccess extends PurchaseState {}

class PurchaseFailure extends PurchaseState {
  final String error;
  PurchaseFailure(this.error);
}

class PurchaseCompleted extends PurchaseState {}

class SubscriptionsLoaded extends PurchaseState {
  final List<PurchaseDetails> subscriptions;
  SubscriptionsLoaded(this.subscriptions);
}

