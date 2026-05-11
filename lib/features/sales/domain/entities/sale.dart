import 'package:flutter/foundation.dart';

@immutable
class Sale {
  final String id;
  final String shopId;
  final DateTime saleDate;
  final double totalAmount;
  final bool isCredit;
  final String? customerId;
  final String staffId;

  const Sale({
    required this.id,
    required this.shopId,
    required this.saleDate,
    required this.totalAmount,
    required this.isCredit,
    this.customerId,
    required this.staffId,
  });

  Sale copyWith({
    String? id,
    String? shopId,
    DateTime? saleDate,
    double? totalAmount,
    bool? isCredit,
    String? customerId,
    String? staffId,
  }) =>
      Sale(
        id: id ?? this.id,
        shopId: shopId ?? this.shopId,
        saleDate: saleDate ?? this.saleDate,
        totalAmount: totalAmount ?? this.totalAmount,
        isCredit: isCredit ?? this.isCredit,
        customerId: customerId ?? this.customerId,
        staffId: staffId ?? this.staffId,
      );
}
