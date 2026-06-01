import 'package:shopkeeper/features/sales/domain/entities/sale_item.dart';

class SaleItemModel {
  final String productId;
  final String unit;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const SaleItemModel({
    required this.productId,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) => SaleItemModel(
        productId: json['product_id'] as String? ?? '',
        unit: json['unit'] as String? ?? '',
        quantity: json['quantity'] as int? ?? 0,
        unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
        totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      );

  SaleItem toEntity() => SaleItem(
        productId: productId,
        unit: unit,
        quantity: quantity,
        unitPrice: unitPrice,
        totalPrice: totalPrice,
      );
}
