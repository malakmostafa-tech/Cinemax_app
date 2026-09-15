import 'package:cinemax_app/core/config/tmdb_config.dart';

class TmdbUserList {
  final int id;
  final String name;
  final String description;
  final int itemCount;
  final String? posterPath;
  final String listType;

  const TmdbUserList({
    required this.id,
    required this.name,
    this.description = '',
    this.itemCount = 0,
    this.posterPath,
    this.listType = 'movie',
  });

  String get displayImage => TmdbConfig.getImageUrl(posterPath);

  factory TmdbUserList.fromJson(Map<String, dynamic> json) {
    return TmdbUserList(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] as String?) ?? 'Untitled List',
      description: (json['description'] as String?) ?? '',
      itemCount: json['item_count'] is int ? json['item_count'] as int : 0,
      posterPath: json['poster_path'] as String?,
      listType: (json['list_type'] as String?) ?? 'movie',
    );
  }
}
