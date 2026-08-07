import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/app_exception.dart';
import '../../catalog/domain/game.dart';
import '../domain/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final Dio _dio;
  
  LibraryRepositoryImpl(this._dio);

  @override
  Future<List<Game>> getMyLibrary() async {
    try {
      final res = await _dio.get('/library');
      final items = res.data['data'] as List? ?? [];
      return items.map((e) => Game.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> addToLibrary(String gameId) async {
    try {
      await _dio.post('/library/$gameId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> removeFromLibrary(String gameId) async {
    try {
      await _dio.delete('/library/$gameId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final code = data['code'] as String? ?? 'UNKNOWN';
        final message = data['message'] as String? ?? 'Có lỗi xảy ra';
        return AppException(code: code, message: message, statusCode: e.response?.statusCode);
      }
    }
    return const AppException.server();
  }
}
