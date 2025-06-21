import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regina_app/domain/appointment.dart';

class UserAppointmentsNotifier extends StateNotifier<AsyncValue<List<Appointment>>> {
  UserAppointmentsNotifier() : super(const AsyncLoading());

  Future<void> loadAppointmentsForUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncLoading();

      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'activo')
          .orderBy('date', descending: false)
          .get();

      final appointments = snapshot.docs
          .map((doc) => Appointment.fromFirestore(doc))
          .toList();

      state = AsyncValue.data(appointments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
  try {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .update({
          'status': 'cancelado',
          'deletedAt': Timestamp.now(),
        });

    await loadAppointmentsForUser();
  } catch (e, st) {
    state = AsyncValue.error(e, st);
  }
}

}

final userAppointmentsProvider =
    StateNotifierProvider<UserAppointmentsNotifier, AsyncValue<List<Appointment>>>(
  (ref) => UserAppointmentsNotifier(),
);
