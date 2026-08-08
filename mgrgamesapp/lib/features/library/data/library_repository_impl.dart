import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../catalog/domain/game.dart';
import '../domain/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final Dio _dio;
  
  LibraryRepositoryImpl(this._dio);

  @override
  Future<List<Game>> getMyLibrary() {
    return safeCall(() async {
      final res = await _dio.get('/library');
      final items = res.data['data'] as List? ?? [];
      return items.map((e) => Game.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  @override
  Future<void> addToLibrary(String gameId) {
    return safeCall(() async {
      await _dio.post('/library/$gameId');
    });
  }

  @override
  Future<void> removeFromLibrary(String gameId) {
    return safeCall(() async {
      await _dio.delete('/library/$gameId');
    });
  }
}
