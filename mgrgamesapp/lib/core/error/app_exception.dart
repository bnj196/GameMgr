/// Chuẩn hóa lỗi theo SRS (AUTH_001, DL_002, NET_001...)
class AppException implements Exception {
  const AppException({required this.code, required this.message, this.statusCode});

  final String code;
  final String message;
  final int? statusCode;

  factory AppException.network() => const AppException(
        code: 'NET_001',
        message: 'Không có kết nối mạng. Vui lòng kiểm tra và thử lại.',
      );

  factory AppException.server() => const AppException(
        code: 'SRV_001',
        message: 'Hệ thống đang bảo trì. Vui lòng thử lại sau.',
      );

  factory AppException.unknown() => const AppException(
        code: 'UNKNOWN',
        message: 'Có lỗi xảy ra. Vui lòng thử lại.',
      );

  @override
  String toString() => '[$code] $message';
}