abstract class UserEvent {}

/// Fired once after authentication to load all user data and check subscription status.
class InitializeUserSession extends UserEvent {}
