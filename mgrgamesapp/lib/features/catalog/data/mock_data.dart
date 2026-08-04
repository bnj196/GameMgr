import '../domain/game.dart';

const _names = [
  'Huyền Thoại Kiếm Khách',
  'Biệt Đội Không Gian',
  'Vương Quốc Sụp Đổ',
  'Đua Xe Thần Tốc',
  'Nông Trại Vui Vẻ',
  'Chiến Trường Huyền Thoại',
  'Giải Đấu MOBA',
  'Thám Hiểm Đại Dương',
];

const _genres = [
  ['RPG', 'Hành động'],
  ['FPS', 'Online'],
  ['RPG', 'Thế giới mở'],
  ['Đua xe', 'Casual'],
  ['Mô phỏng', 'Casual'],
  ['FPS', 'Chiến thuật'],
  ['MOBA', 'Chiến thuật'],
  ['Phiêu lưu', 'Casual'],
];

List<Game> mockGames() {
  return List.generate(_names.length, (i) {
    final id = 'game_${i + 1}';
    return Game(
      id: id,
      name: _names[i],
      shortDescription: 'Mô tả ngắn gọn hấp dẫn cho game demo ${i + 1}.',
      genres: _genres[i],
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