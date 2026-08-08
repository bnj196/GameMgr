import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository, this._tokenStorage) : super(const AuthState());

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;

  /// Kiểm tra phiên khi mở app (splash)
  Future<void> bootstrap() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }
    try {
      final user = await _repository.me();
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (_) {
      await _tokenStorage.clear();
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await _repository.login(
        identifier: identifier,
        password: password,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on AppException catch (e) {
      emit(AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      ));
    }
  }

  Future<void> register({
    required String identifier,
    required String password,
    required String displayName,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await _repository.register(
        identifier: identifier,
        password: password,
        displayName: displayName,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on AppException catch (e) {
      emit(AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      ));
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {}
    await _tokenStorage.clear();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}