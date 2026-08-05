class ApiConstants {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );

  /// true: chạy demo với dữ liệu giả, không cần server
  static const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: false);

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 30);
}