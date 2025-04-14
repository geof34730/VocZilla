import 'package:in_app_purchase/in_app_purchase.dart';

abstract class PurchaseState {}

class PurchaseInitial extends PurchaseState {}

class ProductsLoaded extends PurchaseState {
  final List<ProductDetails> products;
  ProductsLoaded(this.products);
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
