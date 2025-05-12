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

  Future<void> markAsAnsweredCorrectly({required bool isAnswerUser, required String guidVocabulaire}) async {
    final VocabulaireUserRepository vocabulaireUserRepository=VocabulaireUserRepository(context: context);
    final vocabulaireUserBloc = BlocProvider.of<VocabulaireUserBloc>(context);
    Logger.Red.log('markAsAnsweredCorrectly : guidVocabulaire: $guidVocabulaire isAnswerUser: $isAnswerUser' );
    if (isAnswerUser) {
      Logger.Green.log("Bonne réponse de l'utilisateur");
      await vocabulaireUserRepository.addVocabulaireUserDataLearned(vocabularyGuid: guidVocabulaire);
    } else {
      await vocabulaireUserRepository.removeVocabulaireUserDataLearned(vocabularyGuid: guidVocabulaire);
      Logger.Red.log("Pas la bonne réponse de l'utilisateur et suppression de la liste");
    }
    vocabulaireUserBloc.add(CheckVocabulaireUserStatus());

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
