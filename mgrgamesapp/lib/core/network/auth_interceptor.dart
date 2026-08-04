import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

/// Gắn Bearer token và tự refresh khi gặp 401 (SRS-AUTH-05)
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;
  bool _refreshing = false;

  final _refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isAuthPath = options.path.contains('/auth/');
    if (!isAuthPath) {
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
    if (status == 401 && !_refreshing) {
      _refreshing = true;
      try {
        final refreshToken = await _tokenStorage.getRefreshToken();
        if (refreshToken == null) throw Exception('No refresh token');

        final res = await _refreshDio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        final newToken = res.data['data']['accessToken'].toString();
        await _tokenStorage.saveTokens(
          accessToken: newToken,
          refreshToken: refreshToken,
        );

        // Retry request gốc
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';
        final cloned = await _refreshDio.fetch(opts);
        return handler.resolve(cloned);
      } catch (_) {
        await _tokenStorage.clear();
        // TODO: phát event "session expired" để AuthCubit logout
      } finally {
        _refreshing = false;
      }
    }
    handler.next(err);
  }
}