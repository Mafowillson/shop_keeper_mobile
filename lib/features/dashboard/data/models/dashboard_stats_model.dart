import 'package:shopkeeper/features/dashboard/domain/entities/dashboard_stats.dart';

class DashboardStatsModel {
  final double todaySales;
  final int transactionCount;
  final int lowStockCount;
  final double totalDebts;
  final List<double> weeklyRevenue;
  final List<ActivityFeedModel> activityFeed;

  const DashboardStatsModel({
    required this.todaySales,
    required this.transactionCount,
    required this.lowStockCount,
    required this.totalDebts,
    required this.weeklyRevenue,
    required this.activityFeed,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final rawWeekly = json['weekly_revenue'];
    final weekly = rawWeekly is List
        ? rawWeekly.map((e) => (e as num).toDouble()).toList()
        : List<double>.filled(7, 0);

    return DashboardStatsModel(
      todaySales: (json['today_sales'] as num?)?.toDouble() ?? 0,
      transactionCount: (json['transaction_count'] as num?)?.toInt() ?? 0,
      lowStockCount: (json['low_stock_count'] as num?)?.toInt() ?? 0,
      totalDebts: (json['total_debts'] as num?)?.toDouble() ?? 0,
      weeklyRevenue: weekly,
      activityFeed: (json['activity_feed'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(ActivityFeedModel.fromJson)
          .toList(),
    );
  }

  DashboardStats toEntity() => DashboardStats(
        todaySales: todaySales,
        transactionCount: transactionCount,
        lowStockCount: lowStockCount,
        totalDebts: totalDebts,
        weeklyRevenue: weeklyRevenue,
        activityFeed: activityFeed.map((e) => e.toEntity()).toList(),
      );
}

class ActivityFeedModel {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String type;

  const ActivityFeedModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
  });

  factory ActivityFeedModel.fromJson(Map<String, dynamic> json) =>
      ActivityFeedModel(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        type: json['type'] as String,
      );

  ActivityFeed toEntity() => ActivityFeed(
        id: id,
        title: title,
        subtitle: subtitle,
        timestamp: timestamp,
        type: type,
      );
}
