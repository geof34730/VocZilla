import 'package:flutter/foundation.dart';

import '../../core/utils/enum.dart';

class StatutFormNotifier extends ChangeNotifier {
  statutListPerso _statutForm= statutListPerso.create;
  statutListPerso get statutForm => _statutForm;
  void updateStatutFormState(statutListPerso newState) {
    if (_statutForm != newState) {
      _statutForm = newState;
      notifyListeners();
    }
  }
}
