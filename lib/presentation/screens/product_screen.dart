import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:regina_app/domain/cart_item.dart';
import 'package:regina_app/domain/product.dart';
import 'package:regina_app/presentation/providers/cart_provider.dart';
import 'package:regina_app/presentation/providers/image_path_provider.dart';
import 'package:regina_app/presentation/providers/quantity_provider.dart';
import 'package:regina_app/presentation/providers/search_provider.dart';
import 'package:regina_app/presentation/providers/product_provider.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  @override
  void initState() {
    super.initState();

    ref.listenManual<List<CartItem>>(cartProvider, (_, next) {
      final newState = {
        for (final item in next)
          if (item.quantity > 0) item.product.id: item.quantity,
      };
      ref.read(quantityProvider.notifier).setAll(newState);
    });

    Future.microtask(() => ref.read(productProvider.notifier).getAllProducts());
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);
    final filteredProducts = ref.watch(filteredProductsProvider);
    final searchByName = ref.watch(searchByNameProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'Productos',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF007AFF),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(searchByName ? Icons.description : Icons.text_fields),
            tooltip: searchByName ? 'Buscar por descripción' : 'Buscar por nombre',
            onPressed: () {
              ref.read(searchByNameProvider.notifier).state = !searchByName;
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: searchByName
                    ? 'Buscar por nombre...'
                    : 'Buscar por descripción...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
              onChanged: (value) =>
                  ref.read(searchQueryProvider.notifier).state = value,
            ),
          ),
        ),
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _ProductListView(products: filteredProducts),
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
    final quantityMap = ref.watch(quantityProvider);
    final quantity = quantityMap[product.id] ?? 0;

    final imageAsync = ref.watch(
      imagePathProvider(('products', product.imagePath ?? '')),
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () => context.push('/product_detail/${product.id}'),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imageAsync.when(
            data: (url) => Image.network(
              url,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            loading: () => const SizedBox(
              width: 60,
              height: 60,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => const SizedBox(
              width: 60,
              height: 60,
              child: Icon(Icons.image_not_supported),
            ),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          product.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: quantity == 0
            ? IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: Color(0xFF007AFF),
                onPressed: () {
                  ref.read(quantityProvider.notifier).increment(product.id);
                  cartNotifier.addToCart(product, quantity: 1);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} agregado al carrito')),
                  );
                },
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red.shade400,
                    onPressed: () {
                      if (quantity == 1) {
                        ref.read(quantityProvider.notifier).reset(product.id);
                      } else {
                        ref.read(quantityProvider.notifier).decrement(product.id);
                      }
                      cartNotifier.removeOneFromCart(product);
                    },
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: Color(0xFF007AFF),
                    onPressed: () {
                      ref.read(quantityProvider.notifier).increment(product.id);
                      cartNotifier.addToCart(product, quantity: 1);
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
