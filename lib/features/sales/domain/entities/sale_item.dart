import 'package:flutter/foundation.dart';

@immutable
class SaleItem {
  final String productId;
  final String unit;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const SaleItem({
    required this.productId,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}
