import 'package:shopkeeper/features/products/domain/entities/product.dart';

class ProductModel {
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

  const ProductModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.category,
    required this.baseUnit,
    required this.retailPrice,
    required this.cartonPrice,
    required this.cartonQty,
    required this.stockQty,
    required this.lowStockThreshold,
    required this.isActive,
  });

  // ── Parse API response ────────────────────────────────────────────────────
  // Backend returns units[] sorted largest → smallest.
  // We map: base unit (qty==1) → retailPrice, largest unit → cartonPrice/cartonQty.

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final units = (json['units'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    // Find the base unit (quantity_in_base == 1).
    final baseUnitDef = units.firstWhere(
      (u) => (u['quantity_in_base'] as int? ?? 0) == 1,
      orElse: () => units.isNotEmpty ? units.last : <String, dynamic>{},
    );
    final retailPrice = (baseUnitDef['price'] as num?)?.toDouble() ?? 0.0;
    final baseUnitName = baseUnitDef['name'] as String? ?? 'piece';

    // Largest unit is first in the sorted list (or same as base if only one).
    final largestUnit = units.isNotEmpty ? units.first : baseUnitDef;
    final cartonQty = largestUnit['quantity_in_base'] as int? ?? 1;
    final cartonPrice = (largestUnit['price'] as num?)?.toDouble() ?? retailPrice;

    return ProductModel(
      id: json['id'] as String? ?? '',
      shopId: json['shop_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      baseUnit: json['base_unit'] as String? ?? baseUnitName,
      retailPrice: retailPrice,
      cartonPrice: cartonPrice,
      cartonQty: cartonQty,
      stockQty: json['stock_qty'] as int? ?? 0,
      lowStockThreshold: json['low_stock_threshold'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  // ── Build POST /products body ─────────────────────────────────────────────

  Map<String, dynamic> toCreateRequest() {
    final units = <Map<String, dynamic>>[];
    if (cartonQty > 1) {
      units.add({
        'name': 'carton',
        'quantity_in_base': cartonQty,
        'price': cartonPrice,
      });
    }
    units.add({
      'name': baseUnit.isNotEmpty ? baseUnit : 'piece',
      'quantity_in_base': 1,
      'price': retailPrice,
    });

    return {
      'shop_id': shopId,
      'name': name,
      'category': category,
      'units': units,
      'initial_stock': {(baseUnit.isNotEmpty ? baseUnit : 'piece'): stockQty},
      'low_stock_threshold': lowStockThreshold,
    };
  }

  // ── Build PUT /products/:id body ──────────────────────────────────────────

  Map<String, dynamic> toUpdateRequest() {
    final units = <Map<String, dynamic>>[];
    if (cartonQty > 1) {
      units.add({
        'name': 'carton',
        'quantity_in_base': cartonQty,
        'price': cartonPrice,
      });
    }
    units.add({
      'name': baseUnit.isNotEmpty ? baseUnit : 'piece',
      'quantity_in_base': 1,
      'price': retailPrice,
    });

    return {
      'name': name,
      'category': category,
      'units': units,
      'low_stock_threshold': lowStockThreshold,
    };
  }

  // ── Entity ────────────────────────────────────────────────────────────────

  factory ProductModel.fromEntity(Product entity) => ProductModel(
        id: entity.id,
        shopId: entity.shopId,
        name: entity.name,
        category: entity.category,
        baseUnit: entity.baseUnit,
        retailPrice: entity.retailPrice,
        cartonPrice: entity.cartonPrice,
        cartonQty: entity.cartonQty,
        stockQty: entity.stockQty,
        lowStockThreshold: entity.lowStockThreshold,
        isActive: entity.isActive,
      );

  Product toEntity() => Product(
        id: id,
        shopId: shopId,
        name: name,
        category: category,
        baseUnit: baseUnit,
        retailPrice: retailPrice,
        cartonPrice: cartonPrice,
        cartonQty: cartonQty,
        stockQty: stockQty,
        lowStockThreshold: lowStockThreshold,
        isActive: isActive,
      );
}
