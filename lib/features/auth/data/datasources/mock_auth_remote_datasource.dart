import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/features/auth/data/datasources/i_auth_remote_datasource.dart';
import 'package:shopkeeper/features/auth/data/models/user_model.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/mock_data/mock_data.dart';

@LazySingleton(as: IAuthRemoteDataSource)
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
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
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
    );
    MockData.users.add(newUser);
    return UserModel.fromEntity(newUser);
  }

  @override
  Future<UserModel> registerShop({
    required String shopName,
    required String ownerId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final index = MockData.users.indexWhere((u) => u.id == ownerId);
    if (index == -1) {
      throw Exception('User not found');
    }
    final updatedUser = MockData.users[index].copyWith(
      shopId: 'shop_${DateTime.now().millisecondsSinceEpoch}',
    );
    MockData.users[index] = updatedUser;
    return UserModel.fromEntity(updatedUser);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final exists = MockData.users.any((u) => u.email == email);
    if (!exists) {
      throw Exception('Email address not found');
    }
  }
}
