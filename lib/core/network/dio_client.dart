import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopkeeper/core/config/app_config.dart';
import 'package:shopkeeper/core/constants/app_strings.dart';
import 'package:shopkeeper/core/network/token_storage.dart';

class DioClient {
  late final Dio _dio;
  late final _AuthInterceptor _authInterceptor;
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
    _authInterceptor = _AuthInterceptor(_tokenStorage, _dio, _prefs);
    _dio.interceptors.add(_authInterceptor);
  }

  Dio get client => _dio;

  /// Set this once during app initialisation so the interceptor can trigger
  /// a forced logout when the refresh token is gone or rejected by the server.
  set onSessionExpired(VoidCallback? callback) {
    _authInterceptor.onSessionExpired = callback;
  }
}

class _AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final Dio _dio;
  final SharedPreferences _prefs;

  /// Shared refresh future — all concurrent 401s await the same refresh
  /// instead of each kicking off their own, which would rotate the refresh
  /// token multiple times and leave all but the first with an invalid token.
  Future<String>? _pendingRefresh;

  VoidCallback? onSessionExpired;

  _AuthInterceptor(this._tokenStorage, this._dio, this._prefs);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
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
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // The token that was on this request when it was sent.
    final staleHeader = err.requestOptions.headers['Authorization'] as String?;

    try {
      // Fast path: another in-flight request already refreshed the token.
      // If the current stored token is different from what we sent, just
      // retry without starting another refresh cycle.
      final currentToken = await _tokenStorage.getAccessToken();
      if (currentToken != null && 'Bearer $currentToken' != staleHeader) {
        debugPrint('[DioClient] token already refreshed, retrying');
        final retryOptions = err.requestOptions
          ..headers['Authorization'] = 'Bearer $currentToken';
        handler.resolve(await _dio.fetch(retryOptions));
        return;
      }

      // Slow path: we need to refresh. Reuse any in-progress refresh so
      // parallel 401s share a single token exchange instead of each trying
      // to consume the (now-rotated) refresh token.
      _pendingRefresh ??= _doRefresh();
      final newToken = await _pendingRefresh!;

      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newToken';
      handler.resolve(await _dio.fetch(retryOptions));
    } catch (_) {
      handler.next(err);
    } finally {
      _pendingRefresh = null;
    }
  }

  /// Exchanges the stored refresh token for a new access/refresh token pair.
  /// Clears all tokens and fires [onSessionExpired] on any failure.
  Future<String> _doRefresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) {
      await _tokenStorage.clearTokens();
      _notifySessionExpired();
      throw Exception('No refresh token');
    }

    try {
      // Plain Dio instance — must not go through this interceptor.
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
        ),
      );

      final role = await _tokenStorage.getRole() ?? 'owner';
      final endpoint =
          role == 'staff' ? '/auth/staff/refresh' : '/auth/refresh';
      final res = await refreshDio.post(
        endpoint,
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = res.data['token'] as String;
      final newRefreshToken = res.data['refresh_token'] as String;
      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      debugPrint('[DioClient] token refreshed successfully');
      return newAccessToken;
    } catch (e) {
      await _tokenStorage.clearTokens();
      _notifySessionExpired();
      rethrow;
    }
  }

  void _notifySessionExpired() {
    if (onSessionExpired != null) {
      debugPrint('[DioClient] session expired — triggering logout');
      Future.microtask(onSessionExpired!);
    }
  }
}
