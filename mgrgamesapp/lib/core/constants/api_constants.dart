import 'package:flutter/foundation.dart';

class ApiConstants {
  /// Host của backend, ví dụ: http://192.168.1.10:8000
  /// Truyền qua: --dart-define=API_BASE_URL=http://192.168.1.10:8000
  static const _rawBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Đường dẫn gốc của toàn bộ API (backend đăng ký router với prefix /api)
  static const apiPrefix = '/api';

  /// true: chạy demo với dữ liệu giả, không cần server
  static const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: false);

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 30);

  /// Base URL đầy đủ (đã kèm /api). Tự chọn host mặc định theo nền tảng:
  /// Android emulator không thấy 127.0.0.1 của máy host nên phải dùng 10.0.2.2.
  static String get baseUrl {
    final host = _rawBaseUrl.isNotEmpty ? _rawBaseUrl : _defaultHost;
    final normalized = host.endsWith('/')
        ? host.substring(0, host.length - 1)
        : host;
    return normalized.endsWith(apiPrefix)
        ? normalized
        : '$normalized$apiPrefix';
  }

  static String get _defaultHost {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }
}
