import 'package:flutter/foundation.dart';
import 'package:shopkeeper/core/enums/price_type.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';

@immutable
class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final PriceType priceType;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.priceType,
  });

  double get unitPrice =>
      priceType == PriceType.retail ? product.retailPrice : product.cartonPrice;

  double get subtotal => unitPrice * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    PriceType? priceType,
  }) =>
      CartItem(
        id: id ?? this.id,
        product: product ?? this.product,
        quantity: quantity ?? this.quantity,
        priceType: priceType ?? this.priceType,
      );
}
