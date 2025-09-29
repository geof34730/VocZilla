part of 'purchase_is_subscribed_bloc.dart';

abstract class PurchaseIsSubscribedState extends Equatable {
  final bool? isSubscribed;

  const PurchaseIsSubscribedState({this.isSubscribed});

  @override
  List<Object?> get props => [isSubscribed];
}

class PurchaseIsSubscribedInitial extends PurchaseIsSubscribedState {
  PurchaseIsSubscribedInitial() : super(isSubscribed: null);
}

class PurchaseIsSubscribedLoading extends PurchaseIsSubscribedState {
  const PurchaseIsSubscribedLoading({bool? isSubscribed}) : super(isSubscribed: isSubscribed);
}

class PurchaseIsSubscribedLoaded extends PurchaseIsSubscribedState {
  const PurchaseIsSubscribedLoaded({required bool isSubscribed}) : super(isSubscribed: isSubscribed);
}

class PurchaseIsSubscribedError extends PurchaseIsSubscribedState {
  final String message;

  const PurchaseIsSubscribedError(this.message, {bool? isSubscribed}) : super(isSubscribed: isSubscribed);

  @override
  List<Object?> get props => [message, isSubscribed];
}
