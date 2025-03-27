import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/repository/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<CheckUserStatus>(_onCheckUserStatus);
  }

  Future<void> _onCheckUserStatus(CheckUserStatus event, Emitter<UserState> emit) async {
    final isSubscribed = await UserRepository().checkSubscriptionStatus();
    final DateTime? trialEndDate = await UserRepository().getTrialEndDate();
    final int trialLeftDays = await UserRepository().getLeftDaysEndDate();

    DateTime now = DateTime.now().toUtc();
    bool isFreeTrialPeriod = trialEndDate != null && trialEndDate.isAfter(now);
    if (isSubscribed) {
      emit(UserFreeTrialPeriodEndAndSubscribed());
    } else {
      if (isFreeTrialPeriod) {
        emit(UserFreeTrialPeriodAndNotSubscribed(trialLeftDays));
      }
      else{
        emit(UserFreeTrialPeriodEndAndNotSubscribed());
      }
    }
  }
}


