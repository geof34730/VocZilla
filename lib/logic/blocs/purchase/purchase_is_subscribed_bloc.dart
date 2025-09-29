import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:voczilla/data/repository/user_repository.dart';

part 'purchase_is_subscribed_event.dart';
part 'purchase_is_subscribed_state.dart';

class PurchaseIsSubscribedBloc extends Bloc<PurchaseIsSubscribedEvent, PurchaseIsSubscribedState> {
  final UserRepository _userRepository;

  PurchaseIsSubscribedBloc({required UserRepository userRepository}) : _userRepository = userRepository, super(PurchaseIsSubscribedInitial()) {
    on<CheckPurchaseSubscriptionStatus>(_onCheckStatus);
  }

  Future<void> _onCheckStatus(CheckPurchaseSubscriptionStatus event, Emitter<PurchaseIsSubscribedState> emit) async {
    emit(PurchaseIsSubscribedLoading(isSubscribed: state.isSubscribed));
    try {
      final isSubscribed = await _userRepository.checkSubscriptionStatus();
      emit(PurchaseIsSubscribedLoaded(isSubscribed: isSubscribed));
    } catch (e) {
      emit(PurchaseIsSubscribedError(e.toString(), isSubscribed: state.isSubscribed));
    }
  }
}
