import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:regina_app/domain/product.dart';
import 'package:regina_app/presentation/providers/auth_controller_provider.dart';
import 'package:regina_app/presentation/providers/cart_provider.dart';
import 'package:regina_app/presentation/providers/order_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
  
    

    
    final total = ref.watch(cartProvider.notifier).total;

    return Scaffold(
      appBar: AppBar(title: const Text('Carrito'),
       ),
      body: Column(
        children: [
          Expanded(
            child:
                cart.isEmpty
                    ? const Center(child: Text('Tu carrito está vacío.'))
                    : ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                          final item = cart[index];
                        final product = item.product;
                        final quantity = item.quantity;

                        return itemCartCard(product: product,
                         quantity: quantity,
                          cartNotifier: cartNotifier
                          );
                      },
                    ),
                    
          ),

          ElevatedButton(
             onPressed: () {
               final cart = ref.read(cartProvider);
               if (cart.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('El carrito está vacío.')),
                   );
                   return;
                   }
                   context.push('/confirm-order');
                   },
                   child: const Text('Comprar'),
                   ),

          
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

class itemCartCard extends StatelessWidget {
  const itemCartCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.cartNotifier,
  });

  final Product product;
  final int quantity;
  final CartNotifier cartNotifier;

  @override
  
   Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            
              product.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.image_not_supported, size: 60),

              const SizedBox(width: 12),

              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Precio: \$${product.price.toStringAsFixed(2)}'),
                    Text('Subtotal: \$${(product.price * quantity).toStringAsFixed(2)}'),
                  ],
                ),
              ),

              
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          cartNotifier.removeOneFromCart(product);
                        },
                      ),
                      Text('$quantity'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          cartNotifier.addToCart(product, quantity: 1);
                        },
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Eliminar producto'),
                          content: Text('¿Querés eliminar "${product.name}" del carrito?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        cartNotifier.removeAllOf(product);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
