import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regina_app/domain/product.dart';
import 'package:regina_app/presentation/providers/cart_provider.dart';
import 'package:regina_app/presentation/providers/product_provider.dart';
import 'package:regina_app/presentation/providers/quantity_provider.dart';
import 'package:regina_app/presentation/widgets/cart_icon_button.dart';
import 'package:regina_app/presentation/providers/image_path_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productProvider);
    final quantityNotifier = ref.watch(quantityProvider.notifier);
    final cartNotifier = ref.read(cartProvider.notifier);

    final product = products.firstWhere(
      (p) => p.id == productId,
      orElse: () => Product(
        id: '',
        name: 'Producto no encontrado',
        description: '',
        price: 0,
      ),
    );

    final quantity = ref.watch(quantityProvider)[product.id] ?? 1;
    final textStyle = Theme.of(context).textTheme;
    final primaryColor = const Color(0xFF007AFF);
    final imageAsync = ref.watch(
      imagePathProvider(('products', product.imagePath ?? '')),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del producto'),
        actions: const [CartIconButton()],
        foregroundColor: primaryColor,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageAsync.when(
                data: (url) => Image.network(
                  url,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                loading: () => SizedBox(
                  height: 280,
                  child: Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                ),
                error: (_, __) => SizedBox(
                  height: 280,
                  child: Center(
                    child: Icon(Icons.image_not_supported, size: 48, color: const Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              product.name,
              style: textStyle.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    quantityNotifier.decrement(product.id);
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.redAccent,
                  iconSize: 32,
                  tooltip: 'Disminuir cantidad',
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '$quantity',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    quantityNotifier.increment(product.id);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: primaryColor,
                  iconSize: 32,
                  tooltip: 'Aumentar cantidad',
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  cartNotifier.addToCart(product, quantity: quantity);
                  quantityNotifier.reset(product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} agregado al carrito'),
                      backgroundColor: primaryColor,

                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                label: const Text('Agregar al carrito',
                style: TextStyle(color: Colors.white)
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              product.description,
              style: textStyle.bodyLarge,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: textStyle.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
