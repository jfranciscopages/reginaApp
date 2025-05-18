import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final slotsForDayProvider = FutureProvider.family<List<DateTime>, DateTime>((ref, selectedDay) async {
  final dayStart = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
  final dayEnd = dayStart.add(const Duration(days: 1));

  final snapshot = await FirebaseFirestore.instance
      .collection('slots')
      .where('status', isEqualTo: 'available')
      .where('datetime', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
      .where('datetime', isLessThan: Timestamp.fromDate(dayEnd)) // NOT <=, sino <
      .get();

  final slots = snapshot.docs
      .map((doc) => (doc.data()['datetime'] as Timestamp).toDate())
      .toList();

  slots.sort();
  return slots;
});
