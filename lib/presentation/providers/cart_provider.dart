import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regina_app/domain/product.dart';

class CartNotifier extends StateNotifier<List<Product>> {
  CartNotifier() : super([]);

  // Agregar producto al carrito
  void addToCart(Product product) {
    state = [...state, product];
  }

  // Quitar UNA unidad del producto (la última encontrada)
  void removeFromCart(Product product) {
    final index = state.lastIndexOf(product);
    if (index != -1) {
      final updatedCart = [...state]..removeAt(index);
      state = updatedCart;
    }
  }

  // Eliminar completamente un producto (todas sus unidades)
  void removeAllOf(Product product) {
    state = state.where((p) => p != product).toList();
  }

  // Vaciar el carrito completamente
  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<Product>>((ref) {
  return CartNotifier();
});
