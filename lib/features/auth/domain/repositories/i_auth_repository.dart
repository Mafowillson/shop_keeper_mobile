import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';

abstract class IAuthRepository {
  TaskEither<Failure, User> login(String email, String password, UserRole role);
  TaskEither<Failure, Unit> logout();
  TaskEither<Failure, User> register({
    required String name,
    required String email,
    required String password,
  });
  TaskEither<Failure, User> registerShop({
    required String shopName,
    required String ownerId,
  });
  TaskEither<Failure, Unit> forgotPassword(String email);
  TaskEither<Failure, Unit> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
  TaskEither<Failure, User> restoreSession();
  TaskEither<Failure, User> verifyEmail(String code);
  TaskEither<Failure, Unit> resendVerificationCode();
}
