abstract class UserState {}

class UserInitial extends UserState {}
class UserLoading extends UserState {}

/// Represents a fully loaded user session with all necessary data.
class UserSessionLoaded extends UserState {
  final Map<String, dynamic> userData;
  final bool isSubscribed;
  final bool isTrialActive;
  final int trialDaysLeft;

  UserSessionLoaded({
    required this.userData,
    required this.isSubscribed,
    required this.isTrialActive,
    required this.trialDaysLeft,
  });
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}
