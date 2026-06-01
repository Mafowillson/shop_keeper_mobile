import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/staff/domain/entities/staff_dashboard_stats.dart';

abstract class IStaffDashboardRepository {
  TaskEither<Failure, StaffDashboardStats> getStats();
}
