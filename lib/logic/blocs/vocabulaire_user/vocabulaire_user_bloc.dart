import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import 'package:vobzilla/logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../../../core/utils/logger.dart';
import '../user/user_state.dart';


class VocabulaireUserBloc extends Bloc<VocabulaireUserEvent, VocabulaireUserState> {
  VocabulaireUserBloc() : super(VocabulaireUserInitial()) {
    on<CheckVocabulaireUserStatus>(_onCheckVocabulaireUserStatus);
  }
  Future<void> _onCheckVocabulaireUserStatus(CheckVocabulaireUserStatus event,
      Emitter<VocabulaireUserState> emit) async {
        emit(VocabulaireUserUpdate());
  }
}
