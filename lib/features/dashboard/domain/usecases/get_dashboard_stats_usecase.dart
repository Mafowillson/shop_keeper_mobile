import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:shopkeeper/features/dashboard/domain/repositories/i_dashboard_repository.dart';

@lazySingleton
class GetDashboardStatsUseCase {
  final IDashboardRepository _repository;

  const GetDashboardStatsUseCase(this._repository);

  TaskEither<Failure, DashboardStats> call() => _repository.getStats();
}
