import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/auth/domain/entities/shop_summary.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/features/auth/domain/repositories/i_auth_repository.dart';

import '../../../../helpers/fake_providers.dart';

// ── Test users ────────────────────────────────────────────────────────────────

const _user = User(
  id: 'u-1',
  shopId: 'shop-1',
  name: 'Test',
  email: 'test@test.com',
  role: UserRole.owner,
  isActive: true,
  emailVerified: true,
  shopName: 'My Shop',
);

// ── Test repositories ─────────────────────────────────────────────────────────

class _SuccessAuthRepo implements IAuthRepository {
  @override
  TaskEither<Failure, User> login(
          String email, String password, UserRole role) =>
      TaskEither.right(_user);

  @override
  TaskEither<Failure, Unit> logout() => TaskEither.right(unit);

  @override
  TaskEither<Failure, User> register(
          {required String name,
          required String email,
          required String password}) =>
      TaskEither.right(_user);

  @override
  TaskEither<Failure, User> registerShop(
          {required String shopName, required String ownerId}) =>
      TaskEither.right(_user.copyWith(shopName: shopName));

  @override
  TaskEither<Failure, Unit> forgotPassword(String email) =>
      TaskEither.right(unit);

  @override
  TaskEither<Failure, Unit> resetPassword(
          {required String email,
          required String code,
          required String newPassword}) =>
      TaskEither.right(unit);

  @override
  TaskEither<Failure, User> restoreSession() => TaskEither.right(_user);

  @override
  TaskEither<Failure, User> verifyEmail(String code) => TaskEither.right(_user);

  @override
  TaskEither<Failure, Unit> resendVerificationCode() => TaskEither.right(unit);

  @override
  TaskEither<Failure, User> fetchShopInfo() => TaskEither.right(_user);

  @override
  TaskEither<Failure, User> updateShop(
          {required String name, required String description}) =>
      TaskEither.right(_user.copyWith(shopName: name));

  @override
  TaskEither<Failure, List<ShopSummary>> fetchAllShops() => TaskEither.right([
        const ShopSummary(
            id: 'shop-1', name: 'My Shop', description: '', isActive: true)
      ]);

  @override
  TaskEither<Failure, User> setActiveShop(
          {required String shopId,
          required String shopName,
          required String shopDescription}) =>
      TaskEither.right(_user.copyWith(shopId: shopId, shopName: shopName));
}

class _FailingAuthRepo implements IAuthRepository {
  final String message;
  _FailingAuthRepo([this.message = 'Server error']);

  @override
  TaskEither<Failure, User> login(
          String email, String password, UserRole role) =>
      TaskEither.left(AuthFailure(message));

  @override
  TaskEither<Failure, Unit> logout() => TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, User> register(
          {required String name,
          required String email,
          required String password}) =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, User> registerShop(
          {required String shopName, required String ownerId}) =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, Unit> forgotPassword(String email) =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, Unit> resetPassword(
          {required String email,
          required String code,
          required String newPassword}) =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, User> restoreSession() =>
      TaskEither.left(AuthFailure(message));

  @override
  TaskEither<Failure, User> verifyEmail(String code) =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, Unit> resendVerificationCode() =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, User> fetchShopInfo() =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, User> updateShop(
          {required String name, required String description}) =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, List<ShopSummary>> fetchAllShops() =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, User> setActiveShop(
          {required String shopId,
          required String shopName,
          required String shopDescription}) =>
      TaskEither.left(ServerFailure(message));
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── login ─────────────────────────────────────────────────────────────────

  group('AuthProvider — login success', () {
    test('sets currentUser and clears error', () async {
      final p = buildAuthProvider(_SuccessAuthRepo());
      await p.login('test@test.com', 'pass', UserRole.owner);
      expect(p.currentUser, _user);
      expect(p.errorMessage, isNull);
      expect(p.isLoading, isFalse);
    });
  });

  group('AuthProvider — login failure', () {
    test('sets errorMessage and currentUser is null', () async {
      final p = buildAuthProvider(_FailingAuthRepo('Invalid credentials'));
      await p.login('bad@email.com', 'wrong', UserRole.owner);
      expect(p.currentUser, isNull);
      expect(p.errorMessage, 'Invalid credentials');
      expect(p.isLoading, isFalse);
    });
  });

  // ── logout ────────────────────────────────────────────────────────────────

  group('AuthProvider — logout success', () {
    test('clears currentUser and error', () async {
      final p = buildAuthProvider(_SuccessAuthRepo());
      await p.login('test@test.com', 'pass', UserRole.owner);
      expect(p.currentUser, isNotNull);

      await p.logout();
      expect(p.currentUser, isNull);
      expect(p.isLoading, isFalse);
    });
  });

  // ── register ──────────────────────────────────────────────────────────────

  group('AuthProvider — register success', () {
    test('sets currentUser', () async {
      final p = buildAuthProvider(_SuccessAuthRepo());
      await p.register('Test', 'test@test.com', 'pass123');
      expect(p.currentUser, _user);
      expect(p.errorMessage, isNull);
    });
  });

  group('AuthProvider — register failure', () {
    test('sets errorMessage and currentUser is null', () async {
      final p = buildAuthProvider(_FailingAuthRepo('Email in use'));
      await p.register('Test', 'existing@test.com', 'pass');
      expect(p.currentUser, isNull);
      expect(p.errorMessage, 'Email in use');
    });
  });

  // ── registerShop ──────────────────────────────────────────────────────────

  group('AuthProvider — registerShop without currentUser', () {
    test('sets error without calling repo', () async {
      final p = buildAuthProvider(_SuccessAuthRepo());
      // No user set yet
      await p.registerShop('My Shop');
      expect(p.errorMessage, 'No authenticated owner found');
      expect(p.currentUser, isNull);
    });
  });

  group('AuthProvider — registerShop success', () {
    test('sets currentUser with shopName', () async {
      final p = buildAuthProvider(_SuccessAuthRepo());
      // Login first so currentUser is set
      await p.login('test@test.com', 'pass', UserRole.owner);
      await p.registerShop('New Shop');
      expect(p.currentUser?.shopName, 'New Shop');
      expect(p.errorMessage, isNull);
    });
  });

  // ── forgotPassword ────────────────────────────────────────────────────────

  group('AuthProvider — forgotPassword success', () {
    test('returns true', () async {
      final p = buildAuthProvider(_SuccessAuthRepo());
      final result = await p.forgotPassword('test@test.com');
      expect(result, isTrue);
      expect(p.errorMessage, isNull);
    });
  });

  group('AuthProvider — forgotPassword failure', () {
    test('returns false and sets errorMessage', () async {
      final p = buildAuthProvider(_FailingAuthRepo('Email not found'));
      final result = await p.forgotPassword('unknown@test.com');
      expect(result, isFalse);
      expect(p.errorMessage, 'Email not found');
    });
  });

  // ── resetPassword ─────────────────────────────────────────────────────────

  group('AuthProvider — resetPassword success', () {
    test('returns true', () async {
      final p = buildAuthProvider(_SuccessAuthRepo());
      final result = await p.resetPassword(
          email: 'test@test.com', code: '123456', newPassword: 'newpass');
      expect(result, isTrue);
    });
  });

  group('AuthProvider — resetPassword failure', () {
    test('returns false and sets errorMessage', () async {
      final p = buildAuthProvider(_FailingAuthRepo('Invalid code'));
      final result = await p.resetPassword(
          email: 'test@test.com', code: 'bad', newPassword: 'pass');
      expect(result, isFalse);
      expect(p.errorMessage, 'Invalid code');
    });
  });

  // ── tryRestoreSession ─────────────────────────────────────────────────────

  group('AuthProvider — tryRestoreSession success', () {
    test('returns true and sets currentUser', () async {
      final p = buildAuthProvider(_SuccessAuthRepo());
      final result = await p.tryRestoreSession();
      expect(result, isTrue);
      expect(p.currentUser, _user);
    });
  });

  group('AuthProvider — tryRestoreSession failure', () {
    test('returns false and currentUser is null', () async {
      final p = buildAuthProvider(_FailingAuthRepo('No session'));
      final result = await p.tryRestoreSession();
      expect(result, isFalse);
      expect(p.currentUser, isNull);
    });
  });

  // ── verifyEmail ───────────────────────────────────────────────────────────

  group('AuthProvider — verifyEmail success', () {
    test('returns true and sets currentUser', () async {
      final p = buildAuthProvider(_SuccessAuthRepo());
      final result = await p.verifyEmail('123456');
      expect(result, isTrue);
      expect(p.currentUser, _user);
    });
  });

  group('AuthProvider — verifyEmail failure', () {
    test('returns false and sets errorMessage', () async {
      final p = buildAuthProvider(_FailingAuthRepo('Invalid code'));
      final result = await p.verifyEmail('bad');
      expect(result, isFalse);
      expect(p.errorMessage, 'Invalid code');
    });
  });

  // ── resetAuth ─────────────────────────────────────────────────────────────

  group('AuthProvider — resetAuth', () {
    test('clears user, error, and loading state', () async {
      final p = buildAuthProvider(_SuccessAuthRepo());
      await p.login('test@test.com', 'pass', UserRole.owner);
      expect(p.currentUser, isNotNull);

      p.resetAuth();
      expect(p.currentUser, isNull);
      expect(p.errorMessage, isNull);
      expect(p.isLoading, isFalse);
    });
  });

  // ── resendVerificationCode ────────────────────────────────────────────────

  group('AuthProvider — resendVerificationCode success', () {
    test('returns true', () async {
      final p = buildAuthProvider(_SuccessAuthRepo());
      final result = await p.resendVerificationCode();
      expect(result, isTrue);
    });
  });

  group('AuthProvider — resendVerificationCode failure', () {
    test('returns false and sets error', () async {
      final p = buildAuthProvider(_FailingAuthRepo('Rate limited'));
      final result = await p.resendVerificationCode();
      expect(result, isFalse);
      expect(p.errorMessage, 'Rate limited');
    });
  });

  // ── updateShop ────────────────────────────────────────────────────────────

  group('AuthProvider — updateShop success', () {
    test('returns true and updates currentUser shopName', () async {
      final p = buildAuthProvider(_SuccessAuthRepo());
      await p.login('test@test.com', 'pass', UserRole.owner);
      final result =
          await p.updateShop(name: 'Renamed Shop', description: 'desc');
      expect(result, isTrue);
      expect(p.currentUser?.shopName, 'Renamed Shop');
    });
  });

  group('AuthProvider — updateShop failure', () {
    test('returns false and sets error', () async {
      final p = buildAuthProvider(_FailingAuthRepo('Update failed'));
      final result = await p.updateShop(name: 'x', description: 'y');
      expect(result, isFalse);
      expect(p.errorMessage, 'Update failed');
    });
  });
}
