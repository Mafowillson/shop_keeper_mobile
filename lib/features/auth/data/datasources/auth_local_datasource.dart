import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/features/auth/data/datasources/i_auth_local_datasource.dart';
import 'package:shopkeeper/features/auth/data/models/user_model.dart';

@LazySingleton(as: IAuthLocalDataSource)
class AuthLocalDataSource implements IAuthLocalDataSource {
  static const _boxName = 'auth';
  static const _userKey = 'cached_user';

  Box get _box => Hive.box(_boxName);

  @override
  Future<void> cacheUser(UserModel user) async {
    await _box.put(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final raw = _box.get(_userKey) as String?;
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> clearCache() async {
    await _box.delete(_userKey);
  }
}
