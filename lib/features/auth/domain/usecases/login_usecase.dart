import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/features/auth/domain/repositories/i_auth_repository.dart';

@lazySingleton
class LoginUseCase {
  final IAuthRepository _repository;

  const LoginUseCase(this._repository);

  TaskEither<Failure, User> call(String email, String password, UserRole role) =>
      _repository.login(email, password, role);
}
