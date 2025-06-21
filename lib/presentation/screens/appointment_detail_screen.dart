import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:regina_app/presentation/providers/image_path_provider.dart';
import 'package:regina_app/presentation/providers/service_provider.dart';
import 'package:regina_app/presentation/providers/user_appointments_provider.dart';
import '../../domain/service.dart';

class AppointmentDetailScreen extends ConsumerWidget {
  final String appointmentId;

  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(userAppointmentsProvider);

    return appointmentsAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, _) => Scaffold(body: Center(child: Text('Error al cargar: $e'))),
      data: (appointments) {
        final appt = appointments.firstWhere(
          (a) => a.id == appointmentId,
          orElse: () => throw Exception('Turno no encontrado'),
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalle del turno'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<Service?>(
              future: ref
                  .read(serviceProvider.notifier)
                  .getServiceById(appt.serviceId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Servicio no encontrado'));
                }

                final service = snapshot.data!;

                final imageAsync = ref.watch(
                  imagePathProvider(('services', service.imagePath ?? '')),
                );

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      imageAsync.when(
                        data:
                            (url) => Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  url,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        loading:
                            () => const Center(
                              child: SizedBox(
                                height: 180,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                        error:
                            (_, __) => const Center(
                              child: Icon(Icons.broken_image, size: 100),
                            ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Precio: \$${service.price.toStringAsFixed(2)}'),
                      const Divider(height: 32),
                      Text(
                        'Orden #${appt.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Estado: ${appt.status}'),
                      Text(
                        'Fecha: ${DateFormat('dd/MM/yyyy').format(appt.date)}',
                      ),
                      Text('Hora: ${DateFormat('HH:mm').format(appt.date)}'),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancelar turno'),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Cancelar turno'),
                                  content: const Text(
                                    '¿Estás seguro de que querés cancelar este turno?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: const Text('No'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      child: const Text('Sí, cancelar'),
                                    ),
                                  ],
                                ),
                          );

                          if (confirm == true) {
                            context.pop();
                            await ref
                                .read(userAppointmentsProvider.notifier)
                                .cancelAppointment(appt.id);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
