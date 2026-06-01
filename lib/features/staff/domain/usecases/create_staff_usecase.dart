import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/staff/domain/entities/staff_entity.dart';
import 'package:shopkeeper/features/staff/domain/repositories/i_staff_repository.dart';

class CreateStaffUseCase {
  final IStaffRepository _repository;

  const CreateStaffUseCase(this._repository);

  TaskEither<Failure, StaffEntity> call({
    required String name,
    required String email,
    required String phoneNumber,
    String? shopId,
  }) =>
      _repository.createStaff(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        shopId: shopId,
      );
}
