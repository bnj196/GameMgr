import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show VoidCallback;

import '../constants/api_constants.dart';
import '../error/app_exception.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

Dio createDio(TokenStorage tokenStorage, {VoidCallback? onSessionExpired}) {
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

  dio.interceptors.add(
    AuthInterceptor(tokenStorage, onSessionExpired: onSessionExpired),
  );
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
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout) {
      return AppException.network();
    }

    final status = response?.statusCode;
    if (status != null && status >= 500) return AppException.server();

    // FastAPI trả lỗi dạng {"detail": {...}} hoặc {"detail": "..."} /
    // {"detail": [{"loc":..., "msg":...}]} với lỗi validate 422.
    final data = response?.data;
    if (data is Map) {
      final detail = data['detail'] ?? data;

      if (detail is Map) {
        return AppException(
          code: detail['code']?.toString() ?? 'UNKNOWN',
          message: detail['message']?.toString() ??
              detail['msg']?.toString() ??
              'Có lỗi xảy ra.',
          statusCode: status,
        );
      }

      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        return AppException(
          code: 'VALIDATION_001',
          message: first is Map
              ? (first['msg']?.toString() ?? 'Dữ liệu không hợp lệ.')
              : 'Dữ liệu không hợp lệ.',
          statusCode: status,
        );
      }

      return AppException(
        code: 'UNKNOWN',
        message: detail.toString(),
        statusCode: status,
      );
    }

    return AppException.unknown();
  }
}
