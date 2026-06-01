import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/staff/data/datasources/staff_remote_datasource.dart';
import 'package:shopkeeper/features/staff/domain/entities/staff_entity.dart';
import 'package:shopkeeper/features/staff/domain/repositories/i_staff_repository.dart';

class StaffRepositoryImpl implements IStaffRepository {
  final StaffRemoteDataSource _remote;

  const StaffRepositoryImpl(this._remote);

  @override
  TaskEither<Failure, StaffEntity> createStaff({
    required String name,
    required String email,
    required String phoneNumber,
    String? shopId,
  }) =>
      TaskEither.tryCatch(
        () async {
          final model = await _remote.createStaff(
            name: name,
            email: email,
            phoneNumber: phoneNumber,
            shopId: shopId,
          );
          return model.toEntity();
        },
        (e, _) => ServerFailure('$e'),
      );
}
