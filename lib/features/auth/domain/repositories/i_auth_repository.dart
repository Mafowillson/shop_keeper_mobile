import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';

abstract class IAuthRepository {
  TaskEither<Failure, User> login(String email, String password, UserRole role);
  TaskEither<Failure, Unit> logout();
  Option<User> getCurrentUser();
}
