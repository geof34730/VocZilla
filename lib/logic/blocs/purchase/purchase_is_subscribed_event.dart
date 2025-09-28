part of 'purchase_is_subscribed_bloc.dart';

abstract class PurchaseIsSubscribedEvent extends Equatable {
  const PurchaseIsSubscribedEvent();

  @override
  List<Object> get props => [];
}

class CheckPurchaseSubscriptionStatus extends PurchaseIsSubscribedEvent {}
