abstract class UserState {}

class UserInitial extends UserState {}
class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final Map<String, dynamic> userData;
  UserLoaded(this.userData);
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}

class UserFreeTrialPeriodAndNotSubscribed  extends UserState{
  final int daysLeft;
  UserFreeTrialPeriodAndNotSubscribed(this.daysLeft);
}

class UserFreeTrialPeriodEndAndNotSubscribed extends UserState {}

class UserFreeTrialPeriodEndAndSubscribed extends UserState {}
