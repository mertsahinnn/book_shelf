import 'package:flutter_riverpod/flutter_riverpod.dart';

class FloatingButtonState extends StateNotifier<bool> {
  FloatingButtonState() : super(false);

  void toggleFloatingButton() {
    state = !state;
  }
}

final floatingButtonProvider = StateNotifierProvider<FloatingButtonState, bool>(
  (ref) {
    return FloatingButtonState();
  },
);
