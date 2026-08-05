import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/catalog_repository.dart';
import '../domain/game.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<Game>> getGames({String? query, int page = 1, int limit = 20}) {
    return safeCall(() async {
      final res = await _dio.get('/games', queryParameters: {
        if (query != null && query.isNotEmpty) 'q': query,
      });
      final items = res.data['data']['items'] as List? ?? [];
      return items
          .map((e) => Game.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<Game> getGameDetail(String id) {
    return safeCall(() async {
      final res = await _dio.get('/games/$id');
      return Game.fromJson(res.data['data']);
    });
  }

  @override
  Future<String> getDownloadUrl(String gameId) {
    return safeCall(() async {
      final res = await _dio.get('/games/$gameId/download-url');
      return res.data['data']['url'].toString();
    });
  }
}