import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingProvider extends StateNotifier<bool> {
  LoadingProvider() : super(false);

  void toggleLoading() {
    state = !state;
  }
}

final loadingProvider = StateNotifierProvider<LoadingProvider, bool>(
  (ref) {
    return LoadingProvider();
  },
);
