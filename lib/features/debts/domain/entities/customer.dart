import 'package:flutter/foundation.dart';
import 'package:shopkeeper/core/enums/risk_category.dart';

@immutable
class Customer {
  final String id;
  final String shopId;
  final String name;
  final String phone;
  final double totalDebt;
  final RiskCategory riskCategory;
  final int lastPurchaseDaysAgo;

  const Customer({
    required this.id,
    required this.shopId,
    required this.name,
    required this.phone,
    required this.totalDebt,
    required this.riskCategory,
    required this.lastPurchaseDaysAgo,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return (parts.first[0] + parts.last[0]).toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  Customer copyWith({
    String? id,
    String? shopId,
    String? name,
    String? phone,
    double? totalDebt,
    RiskCategory? riskCategory,
    int? lastPurchaseDaysAgo,
  }) =>
      Customer(
        id: id ?? this.id,
        shopId: shopId ?? this.shopId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        totalDebt: totalDebt ?? this.totalDebt,
        riskCategory: riskCategory ?? this.riskCategory,
        lastPurchaseDaysAgo: lastPurchaseDaysAgo ?? this.lastPurchaseDaysAgo,
      );
}
