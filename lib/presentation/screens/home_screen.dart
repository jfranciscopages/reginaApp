import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regina_app/domain/product.dart';
import 'package:regina_app/domain/service.dart';
import 'package:regina_app/presentation/providers/product_provider.dart';
import 'package:regina_app/presentation/providers/service_provider.dart';
import 'package:regina_app/presentation/providers/user_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future.microtask(() => ref.read(productProvider.notifier).getAllProducts());
    Future.microtask(() => ref.read(serviceProvider.notifier).getAllServices());

    final products = ref.watch(productProvider);
    final services = ref.watch(serviceProvider);
    final userAsync = ref.watch(userProvider);
    final userNameAsync = ref.watch(userNameProvider);

    final saludo = userAsync.when(
      data: (user) {
        if (user != null && user.emailVerified) {
          return userNameAsync.when(
            data:
                (nombre) =>
                    nombre != null ? '¡Hola, $nombre! 👋' : '¡Bienvenido! 👋',
            loading: () => 'Cargando nombre...',
            error: (_, __) => '¡Bienvenido! 👋',
          );
        } else {
          return 'Que tengas un hermoso día ✨';
        }
      },
      loading: () => 'Cargando...',
      error: (e, _) => 'Error al cargar usuario',
    );

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          Text(
            saludo,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Center(
            child: Image.asset(
              'assets/images/regina_app_logo.png',
              width: 160,
              height: 160,
            ),
          ),
          const SizedBox(height: 28),
          _SectionHeader(
            title: 'Productos',
            onTap: () => context.push('/products'),
          ),
          const SizedBox(height: 8),
          _HorizontalProductList(products: products),
          const SizedBox(height: 28),
          _SectionHeader(
            title: 'Servicios',
            onTap: () => context.push('/services'),
          ),
          const SizedBox(height: 8),
          _HorizontalServiceList(services: services),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SectionHeader({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(foregroundColor: color),
          child: const Text('Ver más'),
        ),
      ],
    );
  }
}

class _HorizontalProductList extends StatelessWidget {
  final List<Product> products;

  const _HorizontalProductList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () => context.push('/product_detail/${product.id}'),
            child: _SquareCard(imageUrl: product.imageUrl, title: product.name),
          );
        },
      ),
    );
  }
}

class _HorizontalServiceList extends StatelessWidget {
  final List<Service> services;

  const _HorizontalServiceList({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final service = services[index];
          return GestureDetector(
            onTap: () => context.push('/service_detail/${service.id}'),
            child: _SquareCard(imageUrl: service.imageUrl, title: service.name),
          );
        },
      ),
    );
  }
}

class _SquareCard extends StatelessWidget {
  final String? imageUrl;
  final String title;

  const _SquareCard({super.key, required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child:
                  imageUrl != null
                      ? Image.network(imageUrl!, fit: BoxFit.cover)
                      : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 40),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
