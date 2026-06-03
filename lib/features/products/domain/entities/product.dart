import 'package:flutter/foundation.dart';

@immutable
class UnitDefinition {
  final String name;
  final int quantityInBase;
  final double price;

  const UnitDefinition({
    required this.name,
    required this.quantityInBase,
    required this.price,
  });
}

@immutable
class Product {
  final String id;
  final String shopId;
  final String name;
  final String category;
  final String baseUnit;
  final List<UnitDefinition> units;
  final int stockQty;
  final int lowStockThreshold;
  final bool isActive;

  /// Only populated when creating a product — never stored or returned by API.
  final Map<String, int>? initialStock;

  const Product({
    required this.id,
    required this.shopId,
    required this.name,
    required this.category,
    this.baseUnit = '',
    required this.units,
    required this.stockQty,
    required this.lowStockThreshold,
    required this.isActive,
    this.initialStock,
  });

  // ── Backward-compatible getters (used by staff price-list, sale screens) ──

  /// Price of the unit with quantityInBase == 1.
  double get retailPrice {
    if (units.isEmpty) return 0;
    try {
      return units.firstWhere((u) => u.quantityInBase == 1).price;
    } catch (_) {
      return units.last.price;
    }
  }

  /// Price of the largest unit (units are sorted largest first by the backend).
  double get cartonPrice => units.isNotEmpty ? units.first.price : 0;

  /// QuantityInBase of the largest unit.
  int get cartonQty => units.isNotEmpty ? units.first.quantityInBase : 1;

  bool get isLowStock => stockQty > 0 && stockQty <= lowStockThreshold;
  bool get isOutOfStock => stockQty == 0;

  Product copyWith({
    String? name,
    String? category,
    String? baseUnit,
    List<UnitDefinition>? units,
    int? stockQty,
    int? lowStockThreshold,
    bool? isActive,
    Map<String, int>? initialStock,
  }) =>
      Product(
        id: id,
        shopId: shopId,
        name: name ?? this.name,
        category: category ?? this.category,
        baseUnit: baseUnit ?? this.baseUnit,
        units: units ?? this.units,
        stockQty: stockQty ?? this.stockQty,
        lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
        isActive: isActive ?? this.isActive,
        initialStock: initialStock ?? this.initialStock,
      );
}
