import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

@immutable
abstract class PurchaseEvent extends Equatable {
  const PurchaseEvent();
  @override
  List<Object?> get props => const [];
}

class LoadProducts extends PurchaseEvent {
  const LoadProducts();
}

class BuyProduct extends PurchaseEvent {
  final ProductDetails productDetails;
  const BuyProduct(this.productDetails);

  @override
  List<Object?> get props => [productDetails.id];
}

class CheckActiveSubscriptions extends PurchaseEvent {
  const CheckActiveSubscriptions();
}

class PurchaseFailed extends PurchaseEvent {
  final String error;
  const PurchaseFailed(this.error);

  @override
  List<Object?> get props => [error];
}

/// Event interne : les updates viennent du purchaseStream du plugin.
class PurchaseUpdated extends PurchaseEvent {
  final List<PurchaseDetails> details;
  const PurchaseUpdated(this.details);

  @override
  List<Object?> get props =>
      [details.map((d) => d.purchaseID ?? d.productID).toList()];
}
