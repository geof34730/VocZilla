abstract class UserState {}

class UserInitial extends UserState {}

class UserOnFreeTrial extends UserState {
  final DateTime trialEndDate;
  UserOnFreeTrial(this.trialEndDate);
}

class UserSubscribed extends UserState {

}

class UserNotSubscribed extends UserState {
  
}
