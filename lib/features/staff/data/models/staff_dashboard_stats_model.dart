import 'package:shopkeeper/features/staff/domain/entities/staff_dashboard_stats.dart';

class StaffDashboardStatsModel {
  final int mySalesToday;
  final double myRevenueToday;
  final List<RecentSaleItemModel> recentSales;

  const StaffDashboardStatsModel({
    required this.mySalesToday,
    required this.myRevenueToday,
    required this.recentSales,
  });

  factory StaffDashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      StaffDashboardStatsModel(
        mySalesToday: (json['my_sales_today'] as num?)?.toInt() ?? 0,
        myRevenueToday: (json['my_revenue_today'] as num?)?.toDouble() ?? 0,
        recentSales: (json['recent_sales'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
            .map(RecentSaleItemModel.fromJson)
            .toList(),
      );

  StaffDashboardStats toEntity() => StaffDashboardStats(
        mySalesToday: mySalesToday,
        myRevenueToday: myRevenueToday,
        recentSales: recentSales.map((e) => e.toEntity()).toList(),
      );
}

class RecentSaleItemModel {
  final String id;
  final double totalAmount;
  final int itemCount;
  final String? customerId;
  final DateTime createdAt;

  const RecentSaleItemModel({
    required this.id,
    required this.totalAmount,
    required this.itemCount,
    this.customerId,
    required this.createdAt,
  });

  factory RecentSaleItemModel.fromJson(Map<String, dynamic> json) =>
      RecentSaleItemModel(
        id: json['id'] as String,
        totalAmount: (json['total_amount'] as num).toDouble(),
        itemCount: (json['item_count'] as num).toInt(),
        customerId: json['customer_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  RecentSaleItem toEntity() => RecentSaleItem(
        id: id,
        totalAmount: totalAmount,
        itemCount: itemCount,
        customerId: customerId,
        createdAt: createdAt,
      );
}
