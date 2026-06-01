import 'package:shopkeeper/features/auth/data/datasources/i_auth_local_datasource.dart';
import 'package:shopkeeper/features/auth/data/models/user_model.dart';

// Not registered with injectable — real AuthLocalDataSource is used instead.
class MockAuthLocalDataSource implements IAuthLocalDataSource {
  UserModel? _cachedUser;

  @override
  Future<void> cacheUser(UserModel user) async {
    _cachedUser = user;
  }

  @override
  Future<UserModel?> getCachedUser() async {
    return _cachedUser;
  }

  @override
  Future<void> clearCache() async {
    _cachedUser = null;
  }
}
