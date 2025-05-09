import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/logger.dart';
import '../../data/repository/vocabulaire_user_repository.dart';

class AnswerNotifier extends ChangeNotifier {
  bool _hasAnsweredCorrectly = false;

  bool get hasAnsweredCorrectly => _hasAnsweredCorrectly;

  Future<void> markAsAnsweredCorrectly({required bool isAnswerUser, required String guidVocabulaire,required BuildContext context}) async {
    final vocabulaireUserRepository = RepositoryProvider.of<VocabulaireUserRepository>(context);
    if (isAnswerUser) {
      Logger.Green.log("Bonne réponse de l'utilisateur");
      await vocabulaireUserRepository.addVocabularyToLearnedList(guidVocabulaire);
    } else {
      vocabulaireUserRepository.removeVocabularyToLearnedList(guidVocabulaire);
      Logger.Red.log("Pas la bonne réponse de l'utilisateur et suppression de la liste");
    }
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
