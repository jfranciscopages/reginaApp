import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regina_app/domain/order.dart';
import 'package:regina_app/presentation/providers/cart_provider.dart';

final orderProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<PurchaseOrder?>>((ref) {
  return OrderNotifier(ref);
});

class OrderNotifier extends StateNotifier<AsyncValue<PurchaseOrder?>> {
  final Ref ref;

  OrderNotifier(this.ref) : super(const AsyncData(null));

  Future<void> createAndSaveOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = AsyncError('Usuario no autenticado', StackTrace.current);
      return;
    }

    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      state = AsyncError('El carrito está vacío', StackTrace.current);
      return;
    }

    final totalPrice = ref.read(cartProvider.notifier).total;

    final docRef = FirebaseFirestore.instance.collection('purchaseOrders').doc();

    final order = PurchaseOrder(
      id: docRef.id,
      userId: user.uid,
      items: cart,
      totalPrice: totalPrice,
      createdAt: DateTime.now(),
      status: 'Pendiente',
    );

    try {
      state = const AsyncLoading();
      await docRef.set(order.toMap());

      
      ref.read(cartProvider.notifier).clearCart();

      state = AsyncData(order);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
