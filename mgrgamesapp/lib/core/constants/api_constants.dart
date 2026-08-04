class ApiConstants {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com/api/v1',
  );

  /// true: chạy demo với dữ liệu giả, không cần server
  static const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 30);
}