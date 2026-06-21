import 'package:flutter/foundation.dart';

@immutable
class PriceRecommendation {
  final String id;
  final String shopId;
  final String productId;
  final String productName;
  final double sellThroughRate;
  final int unitsSold30d;
  final double avgStock;
  final String
      action; // "increase_5", "increase_3", "decrease_5", "decrease_10"
  final double changePercent;
  final String reason;
  final Map<String, double> currentPrices;
  final Map<String, double> suggestedPrices;
  final String status; // "pending", "accepted", "dismissed"
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? actedAt;

  const PriceRecommendation({
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

  bool get isPending => status == 'pending';
  bool get isIncrease => changePercent > 0;
}
