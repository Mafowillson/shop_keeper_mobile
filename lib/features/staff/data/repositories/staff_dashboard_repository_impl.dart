import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/staff/data/datasources/staff_dashboard_datasource.dart';
import 'package:shopkeeper/features/staff/domain/entities/staff_dashboard_stats.dart';
import 'package:shopkeeper/features/staff/domain/repositories/i_staff_dashboard_repository.dart';

@LazySingleton(as: IStaffDashboardRepository)
class StaffDashboardRepositoryImpl implements IStaffDashboardRepository {
  final IStaffDashboardDataSource _remote;

  const StaffDashboardRepositoryImpl(this._remote);

  @override
  TaskEither<Failure, StaffDashboardStats> getStats() =>
      TaskEither.tryCatch(
        () async => (await _remote.getStats()).toEntity(),
        (e, _) => ServerFailure('Failed to load staff dashboard: $e'),
      );
}
