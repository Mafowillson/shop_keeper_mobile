import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/auth/domain/repositories/i_auth_repository.dart';

@lazySingleton
class ResendVerificationUseCase {
  final IAuthRepository _repository;
  const ResendVerificationUseCase(this._repository);

  TaskEither<Failure, Unit> call() => _repository.resendVerificationCode();
}
