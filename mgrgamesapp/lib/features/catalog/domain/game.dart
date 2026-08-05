enum PriceType { free, paid, subscription }

class Game {
  const Game({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.genres,
    required this.platforms,
    this.thumbnail,
    this.banner,
    this.priceType = PriceType.free,
    this.price,
    this.currency,
    this.owned = false,
    this.sizeGb,
    this.badge,
    this.releaseDate,
    this.version,
  });

  final String id;
  final String name;
  final String shortDescription;
  final List<String> genres;
  final List<String> platforms;
  final String? thumbnail;
  final String? banner;
  final PriceType priceType;
  final double? price;
  final String? currency;
  final bool owned;
  final double? sizeGb;
  final String? badge; // hot | new | sale
  final String? releaseDate;
  final String? version;

  factory Game.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'] as Map<String, dynamic>?;
    final media = json['media'] as Map<String, dynamic>?;
    final ownership = json['ownership'] as Map<String, dynamic>?;

    return Game(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      shortDescription: json['shortDescription']?.toString() ?? '',
      genres: (json['genres'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      platforms: (json['platforms'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      thumbnail: media?['thumbnail']?.toString(),
      banner: media?['banner']?.toString(),
      priceType: switch (pricing?['type']?.toString()) {
        'paid' => PriceType.paid,
        'subscription' => PriceType.subscription,
        _ => PriceType.free,
      },
      price: (pricing?['price'] as num?)?.toDouble(),
      currency: pricing?['currency']?.toString(),
      owned: ownership?['owned'] == true,
      sizeGb: json['sizeInBytes'] is num
          ? (json['sizeInBytes'] as num).toDouble() / (1024 * 1024 * 1024)
          : null,
      badge: json['badge']?.toString(),
      releaseDate: json['releaseDate']?.toString(),
      version: json['version']?.toString(),
    );
  }

  String get priceLabel {
    switch (priceType) {
      case PriceType.free:
        return 'Miễn phí';
      case PriceType.subscription:
        return 'Thuê bao';
      case PriceType.paid:
        return '${price?.toStringAsFixed(0) ?? ''} ${currency ?? 'VND'}';
    }
  }
}