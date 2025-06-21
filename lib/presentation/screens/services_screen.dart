import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:regina_app/domain/service.dart';
import 'package:regina_app/presentation/providers/search_provider.dart';
import 'package:regina_app/presentation/providers/service_provider.dart';
import 'package:regina_app/presentation/providers/storage_provider.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(serviceProvider.notifier).getAllServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(serviceProvider);
    final filteredServices = ref.watch(filteredServicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Buscar servicio...',
                hintStyle: const TextStyle(
                  color: Color.fromARGB(255, 100, 100, 100),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) =>
                  ref.read(searchQueryProvider.notifier).state = value,
            ),
          ),
        ),
      ),
      body: services.isEmpty
          ? const Center(child: Text("No hay servicios"))
          : _ServiceListView(services: filteredServices),
    );
  }
}


class _ServiceListView extends StatelessWidget {
  const _ServiceListView({super.key, required this.services});

  final List<Service> services;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _ServiceItemView(service: services[index]);
      },
    );
  }
}

class _ServiceItemView extends ConsumerWidget {
  const _ServiceItemView({super.key, required this.service});

  final Service service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/service_detail/${service.id}'),
      child: Card(
        child: ListTile(
          trailing: const Icon(Icons.chevron_right),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 50,
              height: 50,
              child: FutureBuilder<String>(
                future: ref.read(storageProvider).getImagePath(
                      folder: 'services',
                      fileName: service.imagePath ?? '',
                    ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2)));
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return const Icon(Icons.calendar_today);
                  } else {
                    return Image.network(
                      snapshot.data!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    );
                  }
                },
              ),
            ),
          ),
          title: Text(service.name),
          subtitle: Text(service.description),
        ),
      ),
    );
  }
}
