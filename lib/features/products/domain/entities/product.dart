import 'package:flutter/foundation.dart';

@immutable
class Product {
  final String id;
  final String shopId;
  final String name;
  final String category;
  final String baseUnit;
  final double retailPrice;
  final double cartonPrice;
  final int cartonQty;
  final int stockQty;
  final int lowStockThreshold;
  final bool isActive;

  const Product({
    required this.id,
    required this.shopId,
    required this.name,
    required this.category,
    this.baseUnit = 'piece',
    required this.retailPrice,
    required this.cartonPrice,
    required this.cartonQty,
    required this.stockQty,
    required this.lowStockThreshold,
    required this.isActive,
  });

  bool get isLowStock => stockQty > 0 && stockQty <= lowStockThreshold;
  bool get isOutOfStock => stockQty == 0;

  Product copyWith({
    String? name,
    String? category,
    String? baseUnit,
    double? retailPrice,
    double? cartonPrice,
    int? cartonQty,
    int? stockQty,
    int? lowStockThreshold,
    bool? isActive,
  }) =>
      Product(
        id: id,
        shopId: shopId,
        name: name ?? this.name,
        category: category ?? this.category,
        baseUnit: baseUnit ?? this.baseUnit,
        retailPrice: retailPrice ?? this.retailPrice,
        cartonPrice: cartonPrice ?? this.cartonPrice,
        cartonQty: cartonQty ?? this.cartonQty,
        stockQty: stockQty ?? this.stockQty,
        lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
        isActive: isActive ?? this.isActive,
      );
}
