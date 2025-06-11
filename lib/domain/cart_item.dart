import 'package:regina_app/domain/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

   CartItem copyWith(
    {
      Product? product,
       int? quantity
       })
   {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'name': product.name,
      'description': product.description,
      'imagePath': product.imagePath,
      'price': product.price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product(
        id: map['productId'],
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        price: map['price'] ?? 0,
        imagePath: map['imagePath'],
        status: map['status'] ?? 'active',
      ),
      quantity: map['quantity'] ?? 1,
    );
  }
}