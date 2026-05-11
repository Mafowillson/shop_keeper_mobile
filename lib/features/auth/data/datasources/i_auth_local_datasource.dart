import 'package:shopkeeper/features/auth/data/models/user_model.dart';

abstract class IAuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
}
