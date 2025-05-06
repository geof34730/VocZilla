import 'package:flutter/foundation.dart';

class ButtonNotifier extends ChangeNotifier {
  bool _showButton = false;
  bool get showButton => _showButton;
  void updateButtonState(bool newState) {
    if (_showButton != newState) {
      _showButton = newState;
      notifyListeners();
    }
  }
}
