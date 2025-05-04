abstract class UpdateState {}

class UpdateInitial extends UpdateState {}

class UpdateAvailable extends UpdateState {}

class UpdateNotAvailable extends UpdateState {}

class UpdateError extends UpdateState {
  final String message;
  UpdateError(this.message);
}
