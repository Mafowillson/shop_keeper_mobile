import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/staff/domain/entities/staff_dashboard_stats.dart';
import 'package:shopkeeper/features/staff/domain/repositories/i_staff_dashboard_repository.dart';

@lazySingleton
class GetStaffDashboardUseCase {
  final IStaffDashboardRepository _repository;

  const GetStaffDashboardUseCase(this._repository);

  TaskEither<Failure, StaffDashboardStats> call() => _repository.getStats();
}
