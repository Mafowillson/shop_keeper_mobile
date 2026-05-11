import 'package:shopkeeper/features/products/domain/entities/product.dart';

class ProductModel {
  final String id;
  final String shopId;
  final String name;
  final String category;
  final double retailPrice;
  final double cartonPrice;
  final int cartonQty;
  final int stockQty;
  final int lowStockThreshold;
  final bool isActive;
  final int? daysUntilStockout;

  const ProductModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.category,
    required this.retailPrice,
    required this.cartonPrice,
    required this.cartonQty,
    required this.stockQty,
    required this.lowStockThreshold,
    required this.isActive,
    this.daysUntilStockout,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'],
    shopId: json['shop_id'],
    name: json['name'],
    category: json['category'],
    retailPrice: (json['retail_price'] as num).toDouble(),
    cartonPrice: (json['carton_price'] as num).toDouble(),
    cartonQty: json['carton_qty'],
    stockQty: json['stock_qty'],
    lowStockThreshold: json['low_stock_threshold'],
    isActive: json['is_active'],
    daysUntilStockout: json['days_until_stockout'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shop_id': shopId,
    'name': name,
    'category': category,
    'retail_price': retailPrice,
    'carton_price': cartonPrice,
    'carton_qty': cartonQty,
    'stock_qty': stockQty,
    'low_stock_threshold': lowStockThreshold,
    'is_active': isActive,
  };

  factory ProductModel.fromEntity(Product entity) => ProductModel(
    id: entity.id,
    shopId: entity.shopId,
    name: entity.name,
    category: entity.category,
    retailPrice: entity.retailPrice,
    cartonPrice: entity.cartonPrice,
    cartonQty: entity.cartonQty,
    stockQty: entity.stockQty,
    lowStockThreshold: entity.lowStockThreshold,
    isActive: entity.isActive,
    daysUntilStockout: entity.daysUntilStockout,
  );

  Product toEntity() => Product(
    id: id,
    shopId: shopId,
    name: name,
    category: category,
    retailPrice: retailPrice,
    cartonPrice: cartonPrice,
    cartonQty: cartonQty,
    stockQty: stockQty,
    lowStockThreshold: lowStockThreshold,
    isActive: isActive,
    daysUntilStockout: daysUntilStockout,
  );

  ProductModel copyWith({
    String? id,
    String? shopId,
    String? name,
    String? category,
    double? retailPrice,
    double? cartonPrice,
    int? cartonQty,
    int? stockQty,
    int? lowStockThreshold,
    bool? isActive,
    int? daysUntilStockout,
  }) =>
      ProductModel(
        id: id ?? this.id,
        shopId: shopId ?? this.shopId,
        name: name ?? this.name,
        category: category ?? this.category,
        retailPrice: retailPrice ?? this.retailPrice,
        cartonPrice: cartonPrice ?? this.cartonPrice,
        cartonQty: cartonQty ?? this.cartonQty,
        stockQty: stockQty ?? this.stockQty,
        lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
        isActive: isActive ?? this.isActive,
        daysUntilStockout: daysUntilStockout ?? this.daysUntilStockout,
      );
}
