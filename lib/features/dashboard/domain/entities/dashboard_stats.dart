import 'package:flutter/foundation.dart';

@immutable
class DashboardStats {
  final double todaySales;
  final int transactionCount;
  final int lowStockCount;
  final double totalDebts;
  final List<ActivityFeed> activityFeed;

  const DashboardStats({
    required this.todaySales,
    required this.transactionCount,
    required this.lowStockCount,
    required this.totalDebts,
    required this.activityFeed,
  });

  DashboardStats copyWith({
    double? todaySales,
    int? transactionCount,
    int? lowStockCount,
    double? totalDebts,
    List<ActivityFeed>? activityFeed,
  }) =>
      DashboardStats(
        todaySales: todaySales ?? this.todaySales,
        transactionCount: transactionCount ?? this.transactionCount,
        lowStockCount: lowStockCount ?? this.lowStockCount,
        totalDebts: totalDebts ?? this.totalDebts,
        activityFeed: activityFeed ?? this.activityFeed,
      );
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
