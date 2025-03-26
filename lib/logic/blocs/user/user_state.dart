abstract class UserState {}

class UserInitial extends UserState {}

class UserOnFreeTrial extends UserState {
  final DateTime trialEndDate;
  UserOnFreeTrial(this.trialEndDate);
}

class UserOnLeftDaysFreeTrial extends UserState{
  final int daysLeft;
  UserOnLeftDaysFreeTrial(this.daysLeft);
}

class UserSubscribed extends UserState {}

class UserNotSubscribed extends UserState {}

class FreeTrialExpired extends UserState {}
