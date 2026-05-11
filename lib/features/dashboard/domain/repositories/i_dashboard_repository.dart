import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/dashboard/domain/entities/dashboard_stats.dart';

abstract class IDashboardRepository {
  TaskEither<Failure, DashboardStats> getStats();
}
