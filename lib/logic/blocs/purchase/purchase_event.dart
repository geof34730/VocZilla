import 'package:in_app_purchase/in_app_purchase.dart';

abstract class PurchaseEvent {}

class LoadProducts extends PurchaseEvent {}

class BuyProduct extends PurchaseEvent {
  final ProductDetails productDetails;

  BuyProduct(this.productDetails);
}

class CheckActiveSubscriptions extends PurchaseEvent {


}
