import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:regina_app/domain/service.dart';
import 'package:regina_app/presentation/providers/service_provider.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(serviceProvider);

 // Future.microtask(() => ref.read(serviceProvider.notifier).getAllServices());

    return Scaffold(
      appBar: AppBar(title: const Text('Servicios')),
      body:
          services.isEmpty
              ? const Center(child: Text("No hay servicios"))
              : _ServiceListView(services: services),
    );
  }
}

class _ServiceListView extends StatelessWidget {
  const _ServiceListView({required this.services});

  final List<Service> services;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _ServiceItemView(
          service: services[index],
        );
      },
    );
  }
}

class _ServiceItemView extends StatelessWidget {
  const _ServiceItemView({required this.service});

  final Service service;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/service_detail/${service.id}'),
      child: Card(
        child: ListTile(
          trailing: const Icon(Icons.chevron_right),
          leading: service.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    service.imageUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              : const SizedBox(
                  width: 50,
                  height: 50,
                  child: Icon(Icons.calendar_today),
                ),
          title: Text(service.name),
          subtitle: Text(service.description),
        ),
      ),
    );
  }
}
