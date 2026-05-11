import 'package:flutter/foundation.dart';

@immutable
class SaleItem {
  final String id;
  final String saleId;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  SaleItem copyWith({
    String? id,
    String? saleId,
    String? productId,
    int? quantity,
    double? unitPrice,
    double? subtotal,
  }) =>
      SaleItem(
        id: id ?? this.id,
        saleId: saleId ?? this.saleId,
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        subtotal: subtotal ?? this.subtotal,
      );
}
