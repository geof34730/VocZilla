class BlocStateTracker {
  static final BlocStateTracker _instance = BlocStateTracker._internal();
  factory BlocStateTracker() => _instance;
  BlocStateTracker._internal();

  final Map<String, dynamic> _blocStates = {};

  void updateState(String blocName, dynamic state) {
    _blocStates[blocName] = state;
  }

  Map<String, dynamic> get blocStates => _blocStates;
}

