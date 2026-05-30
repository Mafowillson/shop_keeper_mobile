import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/auth/data/datasources/i_auth_local_datasource.dart';
import 'package:shopkeeper/features/auth/data/datasources/i_auth_remote_datasource.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/features/auth/domain/repositories/i_auth_repository.dart';

@LazySingleton(as: IAuthRepository)
class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _remote;
  final IAuthLocalDataSource _local;

  const AuthRepositoryImpl(this._remote, this._local);

  @override
  TaskEither<Failure, User> login(String email, String password, UserRole role) =>
      TaskEither.tryCatch(
        () async {
          final model = await _remote.login(email, password, role);
          await _local.cacheUser(model);
          return model.toEntity();
        },
        (e, _) => AuthFailure('Login failed: $e'),
      );

  @override
  TaskEither<Failure, Unit> logout() => TaskEither.tryCatch(
    () async {
      await _remote.logout();
      await _local.clearCache();
      return unit;
    },
    (e, _) => const AuthFailure('Logout failed'),
  );

  @override
  Option<User> getCurrentUser() {
    // This would be implemented with real local storage
    return const None();
  }

  @override
  TaskEither<Failure, User> register({
    required String name,
    required String email,
    required String password,
  }) =>
      TaskEither.tryCatch(
        () async {
          final model = await _remote.register(
            name: name,
            email: email,
            password: password,
          );
          await _local.cacheUser(model);
          return model.toEntity();
        },
        (e, _) => AuthFailure('Registration failed: $e'),
      );

  @override
  TaskEither<Failure, User> registerShop({
    required String shopName,
    required String ownerId,
  }) =>
      TaskEither.tryCatch(
        () async {
          final model = await _remote.registerShop(
            shopName: shopName,
            ownerId: ownerId,
          );
          await _local.cacheUser(model);
          return model.toEntity();
        },
        (e, _) => AuthFailure('Shop registration failed: $e'),
      );

  @override
  TaskEither<Failure, Unit> forgotPassword(String email) => TaskEither.tryCatch(
        () async {
          await _remote.forgotPassword(email);
          return unit;
        },
        (e, _) => AuthFailure('Password reset failed: $e'),
      );
}
