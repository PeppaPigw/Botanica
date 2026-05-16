import 'package:flutter_riverpod/flutter_riverpod.dart';

class CareComboTracker extends StateNotifier<int> {
  CareComboTracker() : super(0);

  DateTime? _lastCompletionTime;
  static const _comboWindow = Duration(minutes: 5);

  int recordCompletion() {
    final now = DateTime.now();
    if (_lastCompletionTime != null &&
        now.difference(_lastCompletionTime!) <= _comboWindow) {
      state++;
    } else {
      state = 1;
    }
    _lastCompletionTime = now;
    return state;
  }

  void reset() {
    state = 0;
    _lastCompletionTime = null;
  }
}

final careComboTrackerProvider =
    StateNotifierProvider<CareComboTracker, int>((ref) => CareComboTracker());
