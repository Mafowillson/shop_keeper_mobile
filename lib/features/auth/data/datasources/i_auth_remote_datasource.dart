import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/features/auth/data/models/user_model.dart';

abstract class IAuthRemoteDataSource {
  Future<UserModel> login(String email, String password, UserRole role);
  Future<void> logout();
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });
  Future<UserModel> registerShop({
    required String shopName,
    required String ownerId,
  });
  Future<void> forgotPassword(String email);
}
