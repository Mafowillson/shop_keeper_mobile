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
  TaskEither<Failure, User> login(
          String email, String password, UserRole role) =>
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
  TaskEither<Failure, User> register({
    required String name,
    required String email,
    required String password,
  }) =>
      TaskEither.tryCatch(
        () async {
          final model = await _remote.register(
              name: name, email: email, password: password);
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
          final shopId = await _remote.registerShop(shopName: shopName);
          final cached = await _local.getCachedUser();
          if (cached == null) throw Exception('No authenticated user found');
          final updated = cached.copyWith(shopId: shopId, shopName: shopName);
          await _local.cacheUser(updated);
          return updated.toEntity();
        },
        (e, _) => AuthFailure('Shop registration failed: $e'),
      );

  @override
  TaskEither<Failure, Unit> forgotPassword(String email) =>
      TaskEither.tryCatch(
        () async {
          await _remote.forgotPassword(email);
          return unit;
        },
        (e, _) => AuthFailure('Request failed: $e'),
      );

  @override
  TaskEither<Failure, Unit> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) =>
      TaskEither.tryCatch(
        () async {
          await _remote.resetPassword(
              email: email, code: code, newPassword: newPassword);
          return unit;
        },
        (e, _) => AuthFailure('$e'),
      );

  @override
  TaskEither<Failure, User> restoreSession() => TaskEither.tryCatch(
        () async {
          final cached = await _local.getCachedUser();
          if (cached == null) throw Exception('No cached session');

          // Attempt a token refresh so the access token is fresh. If this
          // fails (network down, staff token, expired refresh) we still
          // restore from cache — the DioClient interceptor handles 401s on
          // demand when the next API call goes out.
          try {
            final refreshed = await _remote.refreshSession();
            final merged = refreshed.copyWith(
              shopId: refreshed.shopId.isNotEmpty
                  ? refreshed.shopId
                  : cached.shopId,
              shopName: cached.shopName.isNotEmpty
                  ? cached.shopName
                  : refreshed.shopName,
              shopDescription: cached.shopDescription.isNotEmpty
                  ? cached.shopDescription
                  : refreshed.shopDescription,
            );
            await _local.cacheUser(merged);
            return merged.toEntity();
          } catch (_) {
            return cached.toEntity();
          }
        },
        (e, _) => const AuthFailure('Session expired'),
      );

  @override
  TaskEither<Failure, User> verifyEmail(String code) => TaskEither.tryCatch(
        () async {
          final model = await _remote.verifyEmail(code);
          await _local.cacheUser(model);
          return model.toEntity();
        },
        (e, _) => AuthFailure('Verification failed: $e'),
      );

  @override
  TaskEither<Failure, Unit> resendVerificationCode() => TaskEither.tryCatch(
        () async {
          await _remote.resendVerificationCode();
          return unit;
        },
        (e, _) => AuthFailure('Resend failed: $e'),
      );

  @override
  TaskEither<Failure, User> fetchShopInfo() => TaskEither.tryCatch(
        () async {
          final cached = await _local.getCachedUser();
          if (cached == null) throw Exception('No authenticated user found');
          final info = cached.role == UserRole.staff
              ? await _remote.fetchStaffShopInfo()
              : await _remote.fetchShopInfo();
          final updated = cached.copyWith(
            shopName: info.name,
            shopDescription: info.description,
          );
          await _local.cacheUser(updated);
          return updated.toEntity();
        },
        (e, _) => AuthFailure('Failed to load shop info: $e'),
      );
}
