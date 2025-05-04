import 'package:bloc/bloc.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:vobzilla/logic/blocs/update/update_event.dart';
import 'package:vobzilla/logic/blocs/update/update_state.dart';

class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  UpdateBloc() : super(UpdateInitial()) {
    on<CheckForUpdate>(_onCheckForUpdate);
  }

  Future<void> _onCheckForUpdate(CheckForUpdate event, Emitter<UpdateState> emit) async {
    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        emit(UpdateAvailable());
      } else {
        emit(UpdateNotAvailable());
      }
    } catch (e) {
      emit(UpdateError('Error checking for update: $e'));
    }
  }
}
