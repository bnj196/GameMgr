import '../../../core/error/app_exception.dart';
import '../domain/catalog_repository.dart';
import '../domain/game.dart';
import 'mock_data.dart';

class MockCatalogRepository implements CatalogRepository {
  @override
  Future<List<Game>> getGames({String? query, int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final all = mockGames();
    if (query == null || query.isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((g) => g.name.toLowerCase().contains(q)).toList();
  }

  @override
  Future<Game> getGameDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return mockGames().firstWhere((g) => g.id == id);
    } catch (_) {
      throw const AppException(
        code: 'GAME_001',
        message: 'Game không tồn tại hoặc đã ngừng phát hành.',
      );
    }
  }
}