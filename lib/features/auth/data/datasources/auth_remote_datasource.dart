import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/core/network/token_storage.dart';
import 'package:shopkeeper/features/auth/data/datasources/i_auth_remote_datasource.dart';
import 'package:shopkeeper/features/auth/data/models/user_model.dart';

@LazySingleton(as: IAuthRemoteDataSource)
class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthRemoteDataSource(DioClient dioClient, this._tokenStorage)
      : _dio = dioClient.client;

  @override
  Future<UserModel> login(String email, String password, UserRole role) async {
    try {
      if (role == UserRole.owner) {
        final res = await _dio.post('/auth/login',
            data: {'email': email, 'password': password});
        await _saveTokens(res.data);
        return UserModel.fromOwnerLoginResponse(res.data);
      } else {
        final res = await _dio.post('/auth/staff/login',
            data: {'email': email, 'phone_number': password});
        await _saveTokens(res.data);
        return UserModel.fromStaffLoginResponse(res.data);
      }
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post('/auth/register',
          data: {'name': name, 'email': email, 'password': password});
      await _saveTokens(res.data);
      return UserModel.fromOwnerLoginResponse(res.data);
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<String> registerShop({required String shopName}) async {
    try {
      final res = await _dio.post('/shops', data: {'name': shopName});
      return res.data['id'] as String;
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<UserModel> refreshSession() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) throw Exception('No refresh token stored');
      final res = await _dio
          .post('/auth/refresh', data: {'refresh_token': refreshToken});
      await _saveTokens(res.data);
      return UserModel.fromOwnerLoginResponse(res.data);
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await _dio.post('/auth/logout', data: {'refresh_token': refreshToken});
      }
    } catch (_) {
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _dio.post('/auth/reset-password', data: {
        'email': email,
        'code': code,
        'new_password': newPassword,
      });
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<UserModel> verifyEmail(String code) async {
    try {
      final res =
          await _dio.post('/auth/verify-email', data: {'code': code});
      await _saveTokens(res.data);
      return UserModel.fromOwnerLoginResponse(res.data);
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<void> resendVerificationCode() async {
    try {
      await _dio.post('/auth/resend-verification');
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final access = data['token'] as String?;
    final refresh = data['refresh_token'] as String?;
    if (access != null && refresh != null) {
      await _tokenStorage.saveTokens(
          accessToken: access, refreshToken: refresh);
    }
  }

  Exception _toException(DioException e) {
    final msg = e.response?.data is Map
        ? (e.response!.data as Map)['error'] as String? ?? e.message
        : e.message;
    return Exception(msg ?? 'An unexpected error occurred');
  }
}
