import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopkeeper/core/config/app_config.dart';
import 'package:shopkeeper/core/constants/app_strings.dart';
import 'package:shopkeeper/core/network/token_storage.dart';

/// Centralised HTTP client that attaches Accept-Language and Authorization
/// headers to every request based on the user's language preference and stored JWT.
class ApiClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage;
  final SharedPreferences _prefs;

  ApiClient(this._tokenStorage, this._prefs) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(_LangAuthInterceptor(_tokenStorage, _prefs));
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters, options: options);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.post<T>(path,
          data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.put<T>(path,
          data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.patch<T>(path,
          data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.delete<T>(path,
          data: data, queryParameters: queryParameters, options: options);
}

class _LangAuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final SharedPreferences _prefs;

  _LangAuthInterceptor(this._tokenStorage, this._prefs);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final langCode = _prefs.getString(AppStrings.languagePreferenceKey) ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    options.headers['Accept-Language'] = langCode;

    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}
