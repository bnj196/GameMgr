import 'game.dart';

abstract class CatalogRepository {
  Future<List<Game>> getGames({String? query, int page = 1, int limit = 20});
  Future<Game> getGameDetail(String id);
}