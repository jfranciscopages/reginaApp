import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:regina_app/data/product_repository.dart';
import 'package:regina_app/data/service_repository.dart';
import 'package:regina_app/domain/product.dart';
import 'package:regina_app/domain/service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Regina App'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Que tengas un hermoso día ✨', style: textTheme.headlineSmall),
            Image.asset(
              'assets/images/regina_app_logo.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'Productos',
              onTap: () => context.push('/products'),
            ),
            const SizedBox(height: 8),
            _HorizontalProductList(),

            const SizedBox(height: 20),

            _SectionHeader(
              title: 'Servicios',
              onTap: () => context.push('/services'),
            ),
            const SizedBox(height: 8),
            _HorizontalServiceList(),
          ],
        ),
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
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: textTheme.titleLarge),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: onTap,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

class _HorizontalProductList extends StatelessWidget {
  final List<Product> products = productRepository;

  _HorizontalProductList({super.key});

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
  final List<Service> services = serviceRepository;

  _HorizontalServiceList({super.key});

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child:
                  imageUrl != null
                      ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(imageUrl!, fit: BoxFit.cover),
                      )
                      : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 40),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
