import '../../catalog/domain/game.dart';

abstract class LibraryRepository {
  Future<List<Game>> getMyLibrary();
  Future<void> addToLibrary(String gameId);
  Future<void> removeFromLibrary(String gameId);
}

class MockLibraryRepository implements LibraryRepository {
  final List<Game> _games;
  
  MockLibraryRepository({List<Game>? games}) : _games = games ?? [];

  @override
  Future<List<Game>> getMyLibrary() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final all = _games.isNotEmpty ? _games : mockGames();
    return all.where((g) => g.owned).toList();
  }

  @override
  Future<void> addToLibrary(String gameId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // In mock, just simulate success
  }

  @override
  Future<void> removeFromLibrary(String gameId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // In mock, just simulate success
  }
}

List<Game> mockGames() {
  const names = [
    'Huyền Thoại Kiếm Khách',
    'Biệt Đội Không Gian',
    'Vương Quốc Sụp Đổ',
    'Đua Xe Thần Tốc',
    'Nông Trại Vui Vẻ',
    'Chiến Trường Huyền Thoại',
  ];

  const genres = [
    ['RPG', 'Hành động'],
    ['FPS', 'Online'],
    ['RPG', 'Thế giới mở'],
    ['Đua xe', 'Casual'],
    ['Mô phỏng', 'Casual'],
    ['FPS', 'Chiến thuật'],
  ];

  return List.generate(names.length, (i) {
    final id = 'game_${i + 1}';
    return Game(
      id: id,
      name: names[i],
      shortDescription: 'Mô tả ngắn gọn hấp dẫn cho game demo ${i + 1}.',
      genres: genres[i],
      platforms: const ['android', 'ios'],
      thumbnail: 'https://picsum.photos/seed/$id/600/800',
      banner: 'https://picsum.photos/seed/${id}_b/1200/500',
      priceType: i % 3 == 0 ? PriceType.paid : PriceType.free,
      price: i % 3 == 0 ? 120000 + i * 30000.0 : null,
      currency: 'VND',
      owned: i % 2 == 0,
      sizeGb: 1.2 + i * 0.5,
      badge: i == 0 ? 'hot' : (i == 1 ? 'new' : (i == 2 ? 'sale' : null)),
    );
  });
}
