import '../../catalog/data/mock_data.dart';
import '../../catalog/domain/game.dart';
import '../domain/library_repository.dart';

class MockLibraryRepository implements LibraryRepository {
  MockLibraryRepository({List<Game>? games}) : _games = games ?? mockGames();

  final List<Game> _games;
  final Set<String> _ownedIds = {};

  @override
  Future<List<Game>> getMyLibrary() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _games
        .where((g) => g.owned || _ownedIds.contains(g.id))
        .toList();
  }

  @override
  Future<void> addToLibrary(String gameId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _ownedIds.add(gameId);
  }

  @override
  Future<void> removeFromLibrary(String gameId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _ownedIds.remove(gameId);
  }
}
