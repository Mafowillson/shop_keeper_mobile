import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/features/auth/data/models/user_model.dart';

abstract class IAuthRemoteDataSource {
  Future<UserModel> login(String email, String password, UserRole role);
  Future<void> logout();
}
