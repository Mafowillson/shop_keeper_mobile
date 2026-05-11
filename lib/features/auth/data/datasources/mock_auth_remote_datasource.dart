import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/features/auth/data/datasources/i_auth_remote_datasource.dart';
import 'package:shopkeeper/features/auth/data/models/user_model.dart';
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
}
