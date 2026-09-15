import 'package:cinemax_app/core/config/tmdb_config.dart';

class TmdbMediaItem {
  final int id;
  final String title;
  final String mediaType; // 'movie', 'tv', 'episode'
  final String? posterPath;
  final String? backdropPath;
  final String? stillPath;
  final double voteAverage;
  final double? userRating;
  final String releaseDate;
  final String overview;
  final String genre;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? showName;

  const TmdbMediaItem({
    required this.id,
    required this.title,
    required this.mediaType,
    this.posterPath,
    this.backdropPath,
    this.stillPath,
    this.voteAverage = 0.0,
    this.userRating,
    this.releaseDate = '',
    this.overview = '',
    this.genre = 'Action',
    this.seasonNumber,
    this.episodeNumber,
    this.showName,
  });

  String get displayImage {
    if (stillPath != null && stillPath!.isNotEmpty) {
      return TmdbConfig.getImageUrl(stillPath);
    }
    if (posterPath != null && posterPath!.isNotEmpty) {
      return TmdbConfig.getImageUrl(posterPath);
    }
    if (backdropPath != null && backdropPath!.isNotEmpty) {
      return TmdbConfig.getImageUrl(backdropPath);
    }
    return 'https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&w=500&q=80';
  }

  factory TmdbMediaItem.fromJson(Map<String, dynamic> json, {String defaultMediaType = 'movie'}) {
    final mediaType = (json['media_type'] as String?) ?? defaultMediaType;
    final title = json['title'] ?? json['name'] ?? json['original_title'] ?? json['original_name'] ?? 'Untitled';
    final releaseDate = json['release_date'] ?? json['first_air_date'] ?? json['air_date'] ?? '';

    double? userRating;
    if (json.containsKey('rating')) {
      userRating = (json['rating'] as num?)?.toDouble();
    }

    return TmdbMediaItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: title.toString(),
      mediaType: mediaType,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      stillPath: json['still_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      userRating: userRating,
      releaseDate: releaseDate.toString(),
      overview: (json['overview'] as String?) ?? '',
      genre: 'Action',
      seasonNumber: json['season_number'] as int?,
      episodeNumber: json['episode_number'] as int?,
      showName: json['show_name'] as String?,
    );
  }
}
