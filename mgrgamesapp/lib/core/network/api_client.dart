import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../error/app_exception.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

Dio createDio(TokenStorage tokenStorage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(AuthInterceptor(tokenStorage));
  // Bỏ comment khi cần debug:
  // dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  return dio;
}

/// Gói request để map DioException -> AppException chuẩn
Future<T> safeCall<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    throw e.toAppException();
  }
}

extension DioExceptionMapper on DioException {
  AppException toAppException() {
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.connectionError ||
        type == DioExceptionType.receiveTimeout) {
      return AppException.network();
    }

    final status = response?.statusCode;
    if (status != null && status >= 500) return AppException.server();

    final data = response?.data;
    if (data is Map) {
      return AppException(
        code: data['code']?.toString() ?? 'UNKNOWN',
        message: data['message']?.toString() ?? 'Có lỗi xảy ra.',
        statusCode: status,
      );
    }
    return AppException.unknown();
  }
}