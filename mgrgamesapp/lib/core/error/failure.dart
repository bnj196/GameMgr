/// Failure class đại diện cho các trường hợp thất bại trong use case
/// Được sử dụng cùng với Either<Failure, Success> pattern (nếu có)
import '../error/app_exception.dart';

/// Base Failure class
abstract class Failure {
  final String code;
  final String message;
  final int? statusCode;

  const Failure({required this.code, required this.message, this.statusCode});

  @override
  String toString() => '[$code] $message';
}

/// Network Failure - lỗi mạng
class NetworkFailure extends Failure {
  const NetworkFailure() : super(
    code: 'NET_001',
    message: 'Không có kết nối mạng. Vui lòng kiểm tra và thử lại.',
  );
}

/// Server Failure - lỗi server
class ServerFailure extends Failure {
  const ServerFailure() : super(
    code: 'SRV_001',
    message: 'Hệ thống đang bảo trì. Vui lòng thử lại sau.',
  );
}

/// Unknown Failure - lỗi không xác định
class UnknownFailure extends Failure {
  const UnknownFailure() : super(
    code: 'UNKNOWN',
    message: 'Có lỗi xảy ra. Vui lòng thử lại.',
  );
}

/// Auth Failure - lỗi xác thực
class AuthFailure extends Failure {
  const AuthFailure({required String code, required String message, int? statusCode})
      : super(code: code, message: message, statusCode: statusCode);
}

/// Game Failure - lỗi liên quan đến game
class GameFailure extends Failure {
  const GameFailure({required String code, required String message, int? statusCode})
      : super(code: code, message: message, statusCode: statusCode);
}

/// Extension để chuyển AppException sang Failure
extension AppExceptionToFailure on AppException {
  Failure toFailure() {
    switch (code) {
      case 'NET_001':
        return const NetworkFailure();
      case 'SRV_001':
        return const ServerFailure();
      default:
        if (code.startsWith('AUTH')) {
          return AuthFailure(code: code, message: message, statusCode: statusCode);
        } else if (code.startsWith('GAME')) {
          return GameFailure(code: code, message: message, statusCode: statusCode);
        }
        return UnknownFailure();
    }
  }
}
