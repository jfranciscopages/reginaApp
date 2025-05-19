import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regina_app/domain/product.dart';
import 'package:regina_app/presentation/providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    final cartGrouped = <Product, int>{};

    for (var product in cart) {
      cartGrouped[product] = (cartGrouped[product] ?? 0) + 1;
    }

    final total = cartGrouped.entries
        .map((e) => e.key.price * e.value)
        .fold<double>(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: Column(
        children: [
          Expanded(
            child:
                cartGrouped.isEmpty
                    ? const Center(child: Text('Tu carrito está vacío.'))
                    : ListView.builder(
                      itemCount: cartGrouped.length,
                      itemBuilder: (context, index) {
                        final product = cartGrouped.keys.elementAt(index);
                        final quantity = cartGrouped[product]!;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading:
                                product.imageUrl != null
                                    ? Image.network(
                                      product.imageUrl!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                    : const Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                    ),
                            title: Text(product.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Precio: \$${product.price.toStringAsFixed(2)}',
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Subtotal: \$${(product.price * quantity).toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                            trailing: SizedBox(
                              height: 60, // ajustá según tu gusto
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Cantidad: $quantity',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    iconSize: 20, // opcional: más chico
                                    padding:
                                        EdgeInsets
                                            .zero, // elimina padding innecesario
                                    constraints:
                                        const BoxConstraints(), // elimina restricciones extra
                                    onPressed: () {
                                      cartNotifier.removeAllOf(product);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),

          // RESUMEN DEL PEDIDO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Envío:', style: TextStyle(fontSize: 16)),
                    Text('Retiro por local', style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '📍 Retiro de la compra:\nSolo con retiro en el local.\n\n🕒 Horarios:\nLunes a viernes de 9 a 18 hs.\nSábados de 9 a 13 hs.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
