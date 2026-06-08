import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/dashboard/data/datasources/i_dashboard_datasource.dart';
import 'package:shopkeeper/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:shopkeeper/features/dashboard/domain/repositories/i_dashboard_repository.dart';

@LazySingleton(as: IDashboardRepository)
class DashboardRepositoryImpl implements IDashboardRepository {
  final IDashboardRemoteDataSource _remote;

  const DashboardRepositoryImpl(this._remote);

  @override
  TaskEither<Failure, DashboardStats> getStats(String shopId) =>
      TaskEither.tryCatch(
        () async => (await _remote.getStats(shopId)).toEntity(),
        (e, _) => ServerFailure('Failed to load dashboard: $e'),
      );
}
