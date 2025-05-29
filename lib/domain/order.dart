import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:regina_app/domain/cart_item.dart';

class PurchaseOrder {
  String id;
  String userId;
  List<CartItem> items;
  double totalPrice;
  DateTime? createdAt;
  DateTime? deletedAt;
  String status;

  PurchaseOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
  
    this.createdAt,
    this.deletedAt,
    this.status = 'Pendiente',
  });

 factory PurchaseOrder.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PurchaseOrder(
      id: data['id'],
      userId: data['userId'],
      items: (data['items'] as List)
          .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'pendiente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'status': status,
    };
  }

  
}

