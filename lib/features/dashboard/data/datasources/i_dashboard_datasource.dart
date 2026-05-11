import 'package:shopkeeper/features/dashboard/data/models/dashboard_stats_model.dart';

abstract class IDashboardLocalDataSource {
  Future<DashboardStatsModel> getCachedStats();
  Future<void> cacheStats(DashboardStatsModel stats);
}

abstract class IDashboardRemoteDataSource {
  Future<DashboardStatsModel> getStats();
}