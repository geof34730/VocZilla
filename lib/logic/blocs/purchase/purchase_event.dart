import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

abstract class PurchaseEvent  extends Equatable {}

class LoadProducts extends PurchaseEvent {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class BuyProduct extends PurchaseEvent {
  final ProductDetails productDetails;

  BuyProduct(this.productDetails);

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class CheckActiveSubscriptions extends PurchaseEvent {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class PurchaseFailled extends PurchaseEvent {
  PurchaseFailled(String s);

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
