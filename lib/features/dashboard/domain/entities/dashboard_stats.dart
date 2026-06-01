import 'package:flutter/foundation.dart';

@immutable
class DashboardStats {
  final double todaySales;
  final int transactionCount;
  final int lowStockCount;
  final double totalDebts;
  final List<double> weeklyRevenue;
  final List<ActivityFeed> activityFeed;

  const DashboardStats({
    required this.todaySales,
    required this.transactionCount,
    required this.lowStockCount,
    required this.totalDebts,
    required this.weeklyRevenue,
    required this.activityFeed,
  });
}

@immutable
class ActivityFeed {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String type;

  const ActivityFeed({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
  });
}
