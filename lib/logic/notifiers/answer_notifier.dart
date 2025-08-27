import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/logger.dart';
import '../../data/repository/vocabulaire_user_repository.dart';
import '../blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../blocs/vocabulaire_user/vocabulaire_user_state.dart';

class AnswerNotifier extends ChangeNotifier {
  bool _hasAnsweredCorrectly = false;
  bool get hasAnsweredCorrectly => _hasAnsweredCorrectly;
  final BuildContext context;
  AnswerNotifier(this.context);

  Future<void> markAsAnsweredCorrectly({required bool isAnswerUser, required String guidVocabulaire, required String local}) async {
    final VocabulaireUserRepository vocabulaireUserRepository=VocabulaireUserRepository();
    final vocabulaireUserBloc = BlocProvider.of<VocabulaireUserBloc>(context);
    if (isAnswerUser) {
      await vocabulaireUserRepository.addVocabulaireUserDataLearned(vocabularyGuid: guidVocabulaire, local:local);
    } else {
      await vocabulaireUserRepository.removeVocabulaireUserDataLearned(vocabularyGuid: guidVocabulaire);
    }
    vocabulaireUserBloc.add(CheckVocabulaireUserStatus(local: local));
    if (!_hasAnsweredCorrectly) {
      _hasAnsweredCorrectly = true;
      notifyListeners();
    }
  }
  void reset() {
    _hasAnsweredCorrectly = false;
    notifyListeners();
  }
}
