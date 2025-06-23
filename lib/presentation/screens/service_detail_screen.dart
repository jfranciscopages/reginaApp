import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:regina_app/domain/service.dart';
import 'package:regina_app/presentation/providers/service_provider.dart';
import 'package:regina_app/presentation/providers/slots_provider.dart';
import 'package:regina_app/presentation/providers/appointment_provider.dart';
import 'package:regina_app/domain/appointment.dart';
import 'package:regina_app/presentation/providers/user_provider.dart';
import 'package:regina_app/presentation/providers/image_path_provider.dart';

class ServiceDetailScreen extends ConsumerStatefulWidget {
  final String serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  ConsumerState<ServiceDetailScreen> createState() =>
      _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends ConsumerState<ServiceDetailScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _selectedSlot;
  late final Service service;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    final services = ref.read(serviceProvider);
    service = services.firstWhere((s) => s.id == widget.serviceId);
  }

  List<DateTime> _slotsForSelectedDay(List<DateTime> allSlots) {
    if (_selectedDay == null) return [];
    return allSlots.where((slot) => isSameDay(slot, _selectedDay)).toList();
  }

  void _confirmarReserva() async {
    if (_selectedSlot == null) return;

    final userState = ref.read(userProvider);
    final user = userState.value;

    if (user == null) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Iniciar sesión'),
              content: const Text(
                'Necesitás iniciar sesión para reservar un turno.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/login');
                  },
                  child: const Text('Iniciar sesión'),
                ),
              ],
            ),
      );
      return;
    }

    final service = ref
        .read(serviceProvider)
        .firstWhere((s) => s.id == widget.serviceId);

    final appointment = Appointment(
      id: '',
      userId: user.uid,
      serviceId: service.id,
      date: _selectedSlot!,
      createdAt: DateTime.now(),
      deletedAt: null,
    );

    try {
      final notifier = ref.read(appointmentProvider.notifier);
      await notifier.add(appointment);
      final confirmSlot = _selectedSlot!;

      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Reserva confirmada'),
              content: Text(
                'Turno reservado para el ${DateFormat('EEEE d MMMM', 'es').format(confirmSlot)} a las ${DateFormat('HH:mm').format(confirmSlot)}.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                    setState(() {
                      _selectedSlot = null;
                    });
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Error al reservar'),
              content: Text('No se pudo reservar el turno: $e'),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final services = ref.watch(serviceProvider);
    final service = services.firstWhere((s) => s.id == widget.serviceId);
    final slotsAsync = ref.watch(slotsProvider(service.id));
    final imageAsync = ref.watch(
      imagePathProvider(('services', service.imagePath ?? '')),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del servicio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              imageAsync.when(
                data:
                    (url) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(url, height: 180, fit: BoxFit.cover),
                    ),
                loading:
                    () => const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                error:
                    (_, __) => const SizedBox(
                      height: 180,
                      child: Icon(Icons.image_not_supported),
                    ),
              ),
              const SizedBox(height: 12),
              Text(service.name, style: textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(service.description, style: textTheme.bodyMedium),
              const SizedBox(height: 12),
              Text(
                '\$${service.price.toStringAsFixed(2)}',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),

              // CALENDARIO
              TableCalendar(
                locale: 'es',
                focusedDay: _focusedDay,
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 30)),
                calendarFormat: CalendarFormat.week,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                    _selectedSlot = null;
                  });
                },
                headerVisible: true,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),

              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Horarios disponibles:',
                  style: textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),

              slotsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error cargando turnos: $e'),
                data: (slots) {
                  final slotsDelDia = _slotsForSelectedDay(slots);

                  if (slotsDelDia.isEmpty) {
                    return const Text(
                      'No hay turnos disponibles para este día.',
                    );
                  } else {
                    return SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: slotsDelDia.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final slot = slotsDelDia[index];
                          final hora = DateFormat('HH:mm').format(slot);
                          return ChoiceChip(
                            label: Text(hora),
                            selected: _selectedSlot == slot,
                            onSelected: (_) {
                              setState(() {
                                _selectedSlot = slot;
                              });
                            },
                          );
                        },
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _selectedSlot != null ? _confirmarReserva : null,
                icon: const Icon(Icons.check),
                label: const Text('Confirmar turno'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
