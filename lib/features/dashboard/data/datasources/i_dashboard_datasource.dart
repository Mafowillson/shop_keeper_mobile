import 'package:shopkeeper/features/dashboard/data/models/dashboard_stats_model.dart';

abstract class IDashboardRemoteDataSource {
  Future<DashboardStatsModel> getStats(String shopId);
}
