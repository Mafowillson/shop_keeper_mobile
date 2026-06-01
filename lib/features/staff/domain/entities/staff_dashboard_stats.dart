import 'package:flutter/foundation.dart';

@immutable
class StaffDashboardStats {
  final int mySalesToday;
  final double myRevenueToday;
  final List<RecentSaleItem> recentSales;

  const StaffDashboardStats({
    required this.mySalesToday,
    required this.myRevenueToday,
    required this.recentSales,
  });
}

@immutable
class RecentSaleItem {
  final String id;
  final double totalAmount;
  final int itemCount;
  final String? customerId;
  final DateTime createdAt;

  const RecentSaleItem({
    required this.id,
    required this.totalAmount,
    required this.itemCount,
    this.customerId,
    required this.createdAt,
  });
}
