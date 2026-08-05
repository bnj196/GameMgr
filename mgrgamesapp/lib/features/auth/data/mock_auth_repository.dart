import '../domain/auth_repository.dart';
import '../domain/user.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<User> login({
    required String identifier,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // giả lập mạng
    return const User(
      id: 'u1',
      displayName: 'Game Thủ Demo',
      email: 'demo@gamehub.vn',
    );
  }

  @override
  Future<User> register({
    required String identifier,
    required String password,
    required String displayName,
  }) =>
      login(identifier: identifier, password: password);

  @override
  Future<User> me() async => const User(
        id: 'u1',
        displayName: 'Game Thủ Demo',
        email: 'demo@gamehub.vn',
      );

  @override
  Future<void> logout() async {}
}

