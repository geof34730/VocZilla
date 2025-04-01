abstract class UserState {}

class UserInitial extends UserState {}

class UserFreeTrialPeriodAndNotSubscribed  extends UserState{
  final int daysLeft;
  UserFreeTrialPeriodAndNotSubscribed(this.daysLeft);
}

class UserFreeTrialPeriodEndAndNotSubscribed extends UserState {}

class UserFreeTrialPeriodEndAndSubscribed extends UserState {}
