import 'package:injectable/injectable.dart';
import 'package:shopkeeper/features/dashboard/data/datasources/i_dashboard_datasource.dart';
import 'package:shopkeeper/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:shopkeeper/mock_data/mock_data.dart';

@LazySingleton(as: IDashboardRemoteDataSource)
class MockDashboardRemoteDataSource implements IDashboardRemoteDataSource {
  @override
  Future<DashboardStatsModel> getStats() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return DashboardStatsModel.fromEntity(MockData.dashboardStats);
  }
}

@LazySingleton(as: IDashboardLocalDataSource)
class MockDashboardLocalDataSource implements IDashboardLocalDataSource {
  DashboardStatsModel? _cachedStats;

  @override
  Future<DashboardStatsModel> getCachedStats() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_cachedStats != null) {
      return _cachedStats!;
    }
    throw Exception('No cached stats available');
  }

  @override
  Future<void> cacheStats(DashboardStatsModel stats) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _cachedStats = stats;
  }
}