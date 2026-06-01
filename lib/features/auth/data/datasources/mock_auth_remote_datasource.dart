import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/features/auth/data/datasources/i_auth_remote_datasource.dart';
import 'package:shopkeeper/features/auth/data/models/user_model.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/mock_data/mock_data.dart';

// Not registered with injectable — real AuthRemoteDataSource is used in production.
class MockAuthRemoteDataSource implements IAuthRemoteDataSource {
  @override
  Future<UserModel> login(String email, String password, UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final user = MockData.users.firstWhere(
      (u) => u.email == email && u.role == role,
      orElse: () => throw Exception('Invalid credentials'),
    );
    return UserModel.fromEntity(user);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (MockData.users.any((u) => u.email == email)) {
      throw Exception('Email already registered');
    }
    final newUser = User(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      shopId: 'pending',
      name: name,
      email: email,
      role: UserRole.owner,
      isActive: true,
      emailVerified: false,
    );
    MockData.users.add(newUser);
    return UserModel.fromEntity(newUser);
  }

  @override
  Future<String> registerShop({required String shopName}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return 'shop_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<UserModel> refreshSession() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return UserModel.fromEntity(MockData.users.first);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Always succeed — mirrors the real backend behaviour.
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Mock: code '123456' always succeeds.
    if (code != '123456') throw Exception('Invalid reset code');
  }

  @override
  Future<UserModel> verifyEmail(String code) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (code != '123456') throw Exception('Incorrect verification code');
    return UserModel.fromEntity(
        MockData.users.first.copyWith(emailVerified: true));
  }

  @override
  Future<void> resendVerificationCode() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
