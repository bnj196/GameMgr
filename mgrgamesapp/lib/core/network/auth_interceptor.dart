import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show VoidCallback;

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

/// Gắn Bearer token và tự refresh khi gặp 401 (SRS-AUTH-05)
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage, {this.onSessionExpired});

  final TokenStorage _tokenStorage;
  final VoidCallback? onSessionExpired;
  bool _refreshing = false;

  /// Dio riêng, không gắn interceptor để tránh vòng lặp refresh
  final _refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  /// Các endpoint không cần (và không được) gắn access token
  static const _publicPaths = ['/auth/login', '/auth/register', '/auth/refresh'];

  bool _isPublic(String path) => _publicPaths.any(path.contains);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublic(options.path)) {
      final token = await _tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;

    if (status != 401 || _refreshing || _isPublic(path)) {
      return handler.next(err);
    }

    _refreshing = true;
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw DioException(requestOptions: err.requestOptions);
      }

      final res = await _refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final tokens = res.data['data'] as Map<String, dynamic>;
      final newAccessToken = tokens['accessToken'].toString();
      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: tokens['refreshToken']?.toString() ?? refreshToken,
      );

      // Retry request gốc với token mới
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccessToken';
      final cloned = await _refreshDio.fetch(opts);
      return handler.resolve(cloned);
    } catch (_) {
      await _tokenStorage.clear();
      onSessionExpired?.call();
      return handler.next(err);
    } finally {
      _refreshing = false;
    }
  }
}
