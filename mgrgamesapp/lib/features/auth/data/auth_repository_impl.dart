import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dio, this._tokenStorage);

  final Dio _dio;
  final TokenStorage _tokenStorage;

  @override
  Future<User> login({
    required String identifier,
    required String password,
  }) {
    return safeCall(() async {
      final res = await _dio.post('/auth/login', data: {
        'identifier': identifier,
        'password': password,
      });
      final tokens = AuthTokens.fromJson(res.data['data']);
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return me();
    });
  }

  @override
  Future<User> register({
    required String identifier,
    required String password,
    required String displayName,
  }) {
    return safeCall(() async {
      await _dio.post('/auth/register', data: {
        'identifier': identifier,
        'password': password,
        'displayName': displayName,
      });
      return login(identifier: identifier, password: password);
    });
  }

  @override
  Future<User> me() {
    return safeCall(() async {
      final res = await _dio.get('/users/me');
      return User.fromJson(res.data['data']);
    });
  }

  @override
  Future<void> logout() => safeCall(() => _dio.post('/auth/logout'));
}