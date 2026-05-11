import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/dashboard/data/datasources/i_dashboard_datasource.dart';
import 'package:shopkeeper/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:shopkeeper/features/dashboard/domain/repositories/i_dashboard_repository.dart';

@LazySingleton(as: IDashboardRepository)
class DashboardRepositoryImpl implements IDashboardRepository {
  final IDashboardRemoteDataSource _remote;
  final IDashboardLocalDataSource _local;

  const DashboardRepositoryImpl(this._remote, this._local);

  @override
  TaskEither<Failure, DashboardStats> getStats() => TaskEither.tryCatch(
    () async {
      try {
        // Try to get cached data first
        final cached = await _local.getCachedStats();
        return cached.toEntity();
      } catch (_) {
        // If no cache, fetch from remote
        final remote = await _remote.getStats();
        // Cache the result
        await _local.cacheStats(remote);
        return remote.toEntity();
      }
    },
    (e, _) => ServerFailure('Failed to get dashboard stats: $e'),
  );
}