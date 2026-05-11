import 'package:shopkeeper/features/sales/domain/entities/sale_item.dart';

class SaleItemModel {
  final String id;
  final String saleId;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const SaleItemModel({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) => SaleItemModel(
    id: json['id'],
    saleId: json['sale_id'],
    productId: json['product_id'],
    quantity: json['quantity'],
    unitPrice: (json['unit_price'] as num).toDouble(),
    subtotal: (json['subtotal'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sale_id': saleId,
    'product_id': productId,
    'quantity': quantity,
    'unit_price': unitPrice,
    'subtotal': subtotal,
  };

  factory SaleItemModel.fromEntity(SaleItem entity) => SaleItemModel(
    id: entity.id,
    saleId: entity.saleId,
    productId: entity.productId,
    quantity: entity.quantity,
    unitPrice: entity.unitPrice,
    subtotal: entity.subtotal,
  );

  SaleItem toEntity() => SaleItem(
    id: id,
    saleId: saleId,
    productId: productId,
    quantity: quantity,
    unitPrice: unitPrice,
    subtotal: subtotal,
  );

  SaleItemModel copyWith({
    String? id,
    String? saleId,
    String? productId,
    int? quantity,
    double? unitPrice,
    double? subtotal,
  }) =>
      SaleItemModel(
        id: id ?? this.id,
        saleId: saleId ?? this.saleId,
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        subtotal: subtotal ?? this.subtotal,
      );
}
