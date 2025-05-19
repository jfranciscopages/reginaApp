import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:regina_app/domain/product.dart';
import 'package:regina_app/presentation/providers/product_provider.dart';
import 'package:regina_app/presentation/providers/cart_provider.dart'; // <-- nuevo

class ProductScreen extends ConsumerWidget {
  ProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productProvider);
    final cart = ref.watch(cartProvider); // <-- nuevo

   // Future.microtask(() => ref.read(productProvider.notifier).getAllProducts());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => context.push('/cart'), // <-- nueva ruta
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${cart.length}',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: products.isEmpty
          ? const Center(child: Text("No hay productos"))
          : _ProductListView(products: products),
    );
  }
}

class _ProductListView extends StatelessWidget {
  const _ProductListView({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _ProductItemView(product: products[index]);
      },
    );
  }
}

class _ProductItemView extends ConsumerWidget {
  const _ProductItemView({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartProvider.notifier);

    return Card(
      child: ListTile(
        onTap: () => context.push('/product_detail/${product.id}'),
        leading: product.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
            : const SizedBox(
                width: 50,
                height: 50,
                child: Icon(Icons.list_alt_rounded),
              ),
        title: Text(product.name),
        subtitle: Text(product.description),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            cartNotifier.addToCart(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${product.name} agregado al carrito')),
            );
          },
        ),
      ),
    );
  }
}
