import 'package:shopkeeper/features/ai/price_recommendations/domain/entities/price_recommendation.dart';

class PriceRecommendationModel {
  final String id;
  final String shopId;
  final String productId;
  final String productName;
  final double sellThroughRate;
  final int unitsSold30d;
  final double avgStock;
  final String action;
  final double changePercent;
  final String reason;
  final Map<String, double> currentPrices;
  final Map<String, double> suggestedPrices;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? actedAt;

  const PriceRecommendationModel({
    required this.id,
    required this.shopId,
    required this.productId,
    required this.productName,
    required this.sellThroughRate,
    required this.unitsSold30d,
    required this.avgStock,
    required this.action,
    required this.changePercent,
    required this.reason,
    required this.currentPrices,
    required this.suggestedPrices,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.actedAt,
  });

  static Map<String, double> _parseDoubleMap(dynamic raw) {
    if (raw == null) return {};
    final map = raw as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  factory PriceRecommendationModel.fromJson(Map<String, dynamic> json) {
    return PriceRecommendationModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String? ?? '',
      sellThroughRate:
          (json['sell_through_rate'] as num?)?.toDouble() ?? 0.0,
      unitsSold30d: json['units_sold_30d'] as int? ?? 0,
      avgStock: (json['avg_stock'] as num?)?.toDouble() ?? 0.0,
      action: json['action'] as String? ?? '',
      changePercent: (json['change_percent'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] as String? ?? '',
      currentPrices: _parseDoubleMap(json['current_prices']),
      suggestedPrices: _parseDoubleMap(json['suggested_prices']),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      actedAt: json['acted_at'] != null
          ? DateTime.parse(json['acted_at'] as String)
          : null,
    );
  }

  PriceRecommendation toEntity() => PriceRecommendation(
        id: id,
        shopId: shopId,
        productId: productId,
        productName: productName,
        sellThroughRate: sellThroughRate,
        unitsSold30d: unitsSold30d,
        avgStock: avgStock,
        action: action,
        changePercent: changePercent,
        reason: reason,
        currentPrices: currentPrices,
        suggestedPrices: suggestedPrices,
        status: status,
        createdAt: createdAt,
        updatedAt: updatedAt,
        actedAt: actedAt,
      );
}
