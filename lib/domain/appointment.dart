import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String userId;
  final String serviceId;
  final DateTime date;
  final String status;
  final DateTime createdAt;
  final DateTime? deletedAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.date,
    this.status = 'activo',
    required this.createdAt,
    this.deletedAt,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      userId: data['userId'],
      serviceId: data['serviceId'],
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'activo',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      deletedAt:
          data['deletedAt'] != null
              ? (data['deletedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'serviceId': serviceId,
      'date': Timestamp.fromDate(date),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }

  Appointment copyWith({
    String? id,
    String? userId,
    String? serviceId,
    DateTime? date,
    String? status,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      date: date ?? this.date,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
