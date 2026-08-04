import 'user.dart';

abstract class AuthRepository {
  Future<User> login({required String identifier, required String password});
  Future<User> register({
    required String identifier,
    required String password,
    required String displayName,
  });
  Future<User> me();
  Future<void> logout();
}