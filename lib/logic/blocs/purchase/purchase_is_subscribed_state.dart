
part of 'purchase_is_subscribed_bloc.dart';

abstract class PurchaseIsSubscribedState extends Equatable {
  const PurchaseIsSubscribedState();

  @override
  List<Object> get props => [];
}

class PurchaseIsSubscribedInitial extends PurchaseIsSubscribedState {}

class PurchaseIsSubscribedLoading extends PurchaseIsSubscribedState {}

class PurchaseIsSubscribedLoaded extends PurchaseIsSubscribedState {
  final bool isSubscribed;

  const PurchaseIsSubscribedLoaded(this.isSubscribed);

  @override
  List<Object> get props => [isSubscribed];
}

class PurchaseIsSubscribedError extends PurchaseIsSubscribedState {
  final String message;

  const PurchaseIsSubscribedError(this.message);

  @override
  List<Object> get props => [message];
}
