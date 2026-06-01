import 'package:flutter/foundation.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale_item.dart';

@immutable
class Sale {
  final String id;
  final String shopId;
  final String ownerId;
  final String? customerId;
  final List<SaleItem> items;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final bool isCredit;
  final bool isPaid;
  final DateTime createdAt;

  const Sale({
    required this.id,
    required this.shopId,
    required this.ownerId,
    this.customerId,
    required this.items,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.isCredit,
    required this.isPaid,
    required this.createdAt,
  });
}
