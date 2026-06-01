import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/staff/domain/entities/staff_entity.dart';

abstract interface class IStaffRepository {
  TaskEither<Failure, StaffEntity> createStaff({
    required String name,
    required String email,
    required String phoneNumber,
    String? shopId,
  });
}
