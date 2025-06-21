import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:regina_app/domain/appointment.dart';

class AppointmentNotifier extends StateNotifier<List<Appointment>> {
  AppointmentNotifier(this.ref) : super([]);

  final Ref ref;

  Future<void> add(Appointment appointment) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .where('serviceId', isEqualTo: appointment.serviceId)
        .where('date', isEqualTo: Timestamp.fromDate(appointment.date))
        .where('status', isEqualTo: 'activo')
        .get();

    final docRef = await FirebaseFirestore.instance
        .collection('appointments')
        .add({
          ...appointment.toMap(),
          'createdAt': Timestamp.now(),
          'deletedAt': null,
        });

    final addedAppointment = appointment.copyWith(
      id: docRef.id,
      status: 'activo',
      createdAt: DateTime.now(),
      deletedAt: null,
    );

    state = [...state, addedAppointment];
  }

}

final appointmentProvider =
    StateNotifierProvider<AppointmentNotifier, List<Appointment>>((ref) {
      return AppointmentNotifier(ref);
    });
