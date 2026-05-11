import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/auth/domain/repositories/i_auth_repository.dart';

@lazySingleton
class LogoutUseCase {
  final IAuthRepository _repository;

  const LogoutUseCase(this._repository);

  TaskEither<Failure, Unit> call() => _repository.logout();
}
