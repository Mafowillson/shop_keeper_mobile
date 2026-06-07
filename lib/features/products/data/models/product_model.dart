import 'package:shopkeeper/features/products/domain/entities/product.dart';

class ProductModel {
  final String id;
  final String shopId;
  final String name;
  final String category;
  final String baseUnit;
  final List<UnitDefinition> units;
  final int stockQty;
  final int lowStockThreshold;
  final bool isActive;
  final Map<String, int>? initialStock;

  const ProductModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.category,
    required this.baseUnit,
    required this.units,
    required this.stockQty,
    required this.lowStockThreshold,
    required this.isActive,
    this.initialStock,
  });

  // ── API response → model ──────────────────────────────────────────────────

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawUnits =
        (json['units'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

    final units = rawUnits
        .map((u) => UnitDefinition(
              name: u['name'] as String? ?? '',
              quantityInBase: u['quantity_in_base'] as int? ?? 1,
              price: (u['price'] as num?)?.toDouble() ?? 0.0,
            ))
        .toList();

    return ProductModel(
      id: json['id'] as String? ?? '',
      shopId: json['shop_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      baseUnit: json['base_unit'] as String? ?? '',
      units: units,
      stockQty: json['stock_qty'] as int? ?? 0,
      lowStockThreshold: json['low_stock_threshold'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  // ── POST /products body ───────────────────────────────────────────────────

  Map<String, dynamic> toCreateRequest() => {
        'shop_id': shopId,
        'name': name,
        'category': category,
        'units': units
            .map((u) => {
                  'name': u.name,
                  'quantity_in_base': u.quantityInBase,
                  'price': u.price,
                })
            .toList(),
        'initial_stock': initialStock ?? {},
        'low_stock_threshold': lowStockThreshold,
      };

  // ── PUT /products/:id body ────────────────────────────────────────────────

  Map<String, dynamic> toUpdateRequest() => {
        'name': name,
        'category': category,
        'units': units
            .map((u) => {
                  'name': u.name,
                  'quantity_in_base': u.quantityInBase,
                  'price': u.price,
                })
            .toList(),
        'low_stock_threshold': lowStockThreshold,
      };

  // ── Entity ↔ model ────────────────────────────────────────────────────────

  factory ProductModel.fromEntity(Product entity) => ProductModel(
        id: entity.id,
        shopId: entity.shopId,
        name: entity.name,
        category: entity.category,
        baseUnit: entity.baseUnit,
        units: entity.units,
        stockQty: entity.stockQty,
        lowStockThreshold: entity.lowStockThreshold,
        isActive: entity.isActive,
        initialStock: entity.initialStock,
      );

  Product toEntity() => Product(
        id: id,
        shopId: shopId,
        name: name,
        category: category,
        baseUnit: baseUnit,
        units: units,
        stockQty: stockQty,
        lowStockThreshold: lowStockThreshold,
        isActive: isActive,
      );
}
