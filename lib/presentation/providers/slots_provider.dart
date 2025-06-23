import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:table_calendar/table_calendar.dart';

final slotsProvider = StateNotifierProvider.family<
  SlotsNotifier,
  AsyncValue<List<DateTime>>,
  String
>((ref, serviceId) => SlotsNotifier(serviceId));

class SlotsNotifier extends StateNotifier<AsyncValue<List<DateTime>>> {
  final String serviceId;
  StreamSubscription? _subscription;

  SlotsNotifier(this.serviceId) : super(const AsyncValue.loading()) {
    _listenToSlots();
  }

  void _listenToSlots() {
    try {
      _subscription = FirebaseFirestore.instance
          .collection('appointments')
          .where('status', isEqualTo: 'activo')
          .snapshots()
          .listen(
            (snapshot) {
              final reservedSlots =
                  snapshot.docs
                      .map((doc) => (doc['date'] as Timestamp).toDate())
                      .toList();

              final now = DateTime.now();
              final List<DateTime> slots = [];
              for (int i = 0; i < 21; i++) {
                final day = now.add(Duration(days: i));
                for (int hour = 9; hour <= 17; hour += 2) {
                  final slot = DateTime(day.year, day.month, day.day, hour);
                  if (isSameDay(slot, now) && slot.isBefore(now)) {
                    continue;
                  }
                  slots.add(slot);
                }
              }

              final availableSlots =
                  slots.where((slot) {
                    return !reservedSlots.any(
                      (reserved) =>
                          reserved.year == slot.year &&
                          reserved.month == slot.month &&
                          reserved.day == slot.day &&
                          reserved.hour == slot.hour,
                    );
                  }).toList();

              state = AsyncValue.data(availableSlots);
            },
            onError: (error, stack) {
              state = AsyncValue.error(error, stack);
            },
          );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
