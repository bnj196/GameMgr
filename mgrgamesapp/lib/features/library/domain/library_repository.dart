import '../../catalog/domain/game.dart';

abstract class LibraryRepository {
  Future<List<Game>> getMyLibrary();
  Future<void> addToLibrary(String gameId);
  Future<void> removeFromLibrary(String gameId);
}
