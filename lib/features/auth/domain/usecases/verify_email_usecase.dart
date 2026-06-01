import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/features/auth/domain/repositories/i_auth_repository.dart';

@lazySingleton
class VerifyEmailUseCase {
  final IAuthRepository _repository;
  const VerifyEmailUseCase(this._repository);

  TaskEither<Failure, User> call(String code) =>
      _repository.verifyEmail(code);
}
