import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:regina_app/presentation/providers/cart_provider.dart';
import 'package:regina_app/presentation/providers/order_provider.dart';

class PurchaseConfirmationScreen extends ConsumerWidget {
  const PurchaseConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = ref.read(cartProvider.notifier).total;
    final orderNotifier = ref.read(orderProvider.notifier);
    final orderState = ref.watch(orderProvider);
    final user = FirebaseAuth.instance.currentUser;

   if (user == null) {
    Future.microtask(() async {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debés iniciar sesión para confirmar la compra'),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      context.go('/login');
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmación de compra')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de tu pedido:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final item = cart[index];
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('Cantidad: ${item.quantity}'),
                    trailing: Text('\$${(item.product.price * item.quantity).toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: orderState.isLoading
               ? const CircularProgressIndicator()
               : ElevatedButton(
                 onPressed: () async {
                   final confirm = await showDialog<bool>(
                    context: context,
                 builder: (context) => AlertDialog(
                    title: const Text('¿Confirmar compra?'),
                    content: const Text('¿Estás segura/o de realizar esta compra?'),
                   actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirmar'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await ref.read(orderProvider.notifier).createAndSaveOrder();
            final state = ref.read(orderProvider);
            if (state is AsyncData && state.value != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Compra realizada con éxito'),
                  duration: Duration(seconds: 2)
                  ),
                  );
              context.go('/order-summary');
            } else if (state.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No se pudo generar la orden.')),
              );
            }
          }
        },
        child: const Text('Confirmar compra'),
      )
            ),
          ],
        ),
      ),
    );
  }
}
