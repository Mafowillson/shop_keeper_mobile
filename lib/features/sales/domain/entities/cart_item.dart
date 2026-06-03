import 'package:flutter/foundation.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';

@immutable
class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final UnitDefinition unit;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unit,
  });

  double get unitPrice => unit.price;
  double get subtotal => unitPrice * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    UnitDefinition? unit,
  }) =>
      CartItem(
        id: id ?? this.id,
        product: product ?? this.product,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
      );
}
