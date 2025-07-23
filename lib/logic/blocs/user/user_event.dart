abstract class UserEvent {}

class CheckUserStatus extends UserEvent {}


class LoadUserData extends UserEvent {
  final String userId;
  LoadUserData(this.userId);
}
