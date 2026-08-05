import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/catalog_repository.dart';
import '../domain/game.dart';

class MockCatalogRepository implements CatalogRepository {
  final List<Game> _games;

  MockCatalogRepository({List<Game>? games}) : _games = games ?? [];

  @override
  Future<List<Game>> getGames({String? query, int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final all = _games.isNotEmpty ? _games : mockGames();
    if (query == null || query.isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((g) => g.name.toLowerCase().contains(q)).toList();
  }

  @override
  Future<Game> getGameDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return (_games.isNotEmpty ? _games : mockGames()).firstWhere((g) => g.id == id);
    } catch (_) {
      throw const AppException(
        code: 'GAME_001',
        message: 'Game không tồn tại hoặc đã ngừng phát hành.',
      );
    }
  }

  @override
  Future<String> getDownloadUrl(String gameId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return 'https://cdn.gamehub.mock/packages/$gameId.pkg';
  }
}