import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuantityNotifier extends StateNotifier<Map<String, int>> {
  QuantityNotifier() : super({});

  void setAll(Map<String, int> quantities) {
    state = quantities;
  }

  void increment(String productId) {
    final current = state[productId] ?? 0;
    state = {...state, productId: current + 1};
  }

  void decrement(String productId) {
    final current = state[productId] ?? 0;
    if (current > 1) {
      state = {...state, productId: current - 1};
    }
  }

  void reset(String productId) {
    final newState = Map<String, int>.from(state);
    newState.remove(productId);
    state = newState;
  }

  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      reset(productId);
    } else {
      state = {...state, productId: quantity};
    }
  }

  void resetAll() {
    state = {};
  }
}

final quantityProvider =
    StateNotifierProvider<QuantityNotifier, Map<String, int>>(
      (ref) => QuantityNotifier(),
    );
