import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/auth/domain/repositories/i_auth_repository.dart';

@lazySingleton
class ResetPasswordUseCase {
  final IAuthRepository _repository;
  const ResetPasswordUseCase(this._repository);

  TaskEither<Failure, Unit> call({
    required String email,
    required String code,
    required String newPassword,
  }) =>
      _repository.resetPassword(
          email: email, code: code, newPassword: newPassword);
}
