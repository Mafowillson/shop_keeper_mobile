import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopkeeper/core/config/app_config.dart';
import 'package:shopkeeper/core/constants/app_strings.dart';
import 'package:shopkeeper/core/network/token_storage.dart';

class DioClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage;
  final SharedPreferences _prefs;

  DioClient(this._tokenStorage, this._prefs) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(_AuthInterceptor(_tokenStorage, _dio, _prefs));
  }

  Dio get client => _dio;
}

class _AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final Dio _dio;
  final SharedPreferences _prefs;
  bool _isRefreshing = false;

  _AuthInterceptor(this._tokenStorage, this._dio, this._prefs);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Explicit in-app language preference overrides the device locale so the
    // backend responds in whatever language the user chose in settings.
    final langCode = _prefs.getString(AppStrings.languagePreferenceKey) ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    options.headers['Accept-Language'] = langCode;

    try {
      final token = await _tokenStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        debugPrint('[DioClient] ✓ token attached for ${options.path}');
      } else {
        debugPrint('[DioClient] ✗ no token for ${options.path}');
      }
    } catch (e) {
      debugPrint('[DioClient] token read failed: $e');
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 || _isRefreshing) {
      handler.next(err);
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        await _tokenStorage.clearTokens();
        handler.next(err);
        return;
      }

      // Use a plain Dio instance to avoid interceptor loop.
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
        ),
      );

      final role = await _tokenStorage.getRole() ?? 'owner';
      final refreshEndpoint =
          role == 'staff' ? '/auth/staff/refresh' : '/auth/refresh';
      final refreshResponse = await refreshDio.post(
        refreshEndpoint,
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = refreshResponse.data['token'] as String;
      final newRefreshToken = refreshResponse.data['refresh_token'] as String;
      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      // Retry the original request with the new token.
      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await _dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      await _tokenStorage.clearTokens();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
