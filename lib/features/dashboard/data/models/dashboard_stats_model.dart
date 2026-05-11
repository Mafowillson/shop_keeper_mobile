import 'package:shopkeeper/features/dashboard/domain/entities/dashboard_stats.dart';

class DashboardStatsModel {
  final double todaySales;
  final int transactionCount;
  final int lowStockCount;
  final double totalDebts;
  final List<ActivityFeedModel> activityFeed;

  const DashboardStatsModel({
    required this.todaySales,
    required this.transactionCount,
    required this.lowStockCount,
    required this.totalDebts,
    required this.activityFeed,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) => DashboardStatsModel(
    todaySales: (json['today_sales'] as num).toDouble(),
    transactionCount: json['transaction_count'],
    lowStockCount: json['low_stock_count'],
    totalDebts: (json['total_debts'] as num).toDouble(),
    activityFeed: (json['activity_feed'] as List)
        .map((e) => ActivityFeedModel.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'today_sales': todaySales,
    'transaction_count': transactionCount,
    'low_stock_count': lowStockCount,
    'total_debts': totalDebts,
    'activity_feed': activityFeed.map((e) => e.toJson()).toList(),
  };

  factory DashboardStatsModel.fromEntity(DashboardStats entity) => DashboardStatsModel(
    todaySales: entity.todaySales,
    transactionCount: entity.transactionCount,
    lowStockCount: entity.lowStockCount,
    totalDebts: entity.totalDebts,
    activityFeed: entity.activityFeed
        .map((e) => ActivityFeedModel.fromEntity(e))
        .toList(),
  );

  DashboardStats toEntity() => DashboardStats(
    todaySales: todaySales,
    transactionCount: transactionCount,
    lowStockCount: lowStockCount,
    totalDebts: totalDebts,
    activityFeed: activityFeed.map((e) => e.toEntity()).toList(),
  );

  DashboardStatsModel copyWith({
    double? todaySales,
    int? transactionCount,
    int? lowStockCount,
    double? totalDebts,
    List<ActivityFeedModel>? activityFeed,
  }) =>
      DashboardStatsModel(
        todaySales: todaySales ?? this.todaySales,
        transactionCount: transactionCount ?? this.transactionCount,
        lowStockCount: lowStockCount ?? this.lowStockCount,
        totalDebts: totalDebts ?? this.totalDebts,
        activityFeed: activityFeed ?? this.activityFeed,
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

  factory ActivityFeedModel.fromJson(Map<String, dynamic> json) => ActivityFeedModel(
    id: json['id'],
    title: json['title'],
    subtitle: json['subtitle'],
    timestamp: DateTime.parse(json['timestamp']),
    type: json['type'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'timestamp': timestamp.toIso8601String(),
    'type': type,
  };

  factory ActivityFeedModel.fromEntity(ActivityFeed entity) => ActivityFeedModel(
    id: entity.id,
    title: entity.title,
    subtitle: entity.subtitle,
    timestamp: entity.timestamp,
    type: entity.type,
  );

  ActivityFeed toEntity() => ActivityFeed(
    id: id,
    title: title,
    subtitle: subtitle,
    timestamp: timestamp,
    type: type,
  );
}
