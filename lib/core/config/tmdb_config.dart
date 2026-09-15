class TmdbConfig {
  TmdbConfig._();

  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // Read Access Token loaded from environment variable or default fallback token
  static const String readAccessToken = String.fromEnvironment(
    'TMDB_READ_ACCESS_TOKEN',
    defaultValue: 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzYzZhMjg0ZTE1NGRmNDMyYjc1MzljNTI5ZDE3MWIwMyIsIm5iZiI6MTc4ODM4ODUwOC44NCwic3ViIjoiNmE5OGE0OWM2N2E2N2IzODJjNWU1YzIyIiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.wfkacaJVPQldkszRyrfm-mXvcS8SM9KNPy2r_40bJ34',
  );

  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&w=500&q=80';
    }
    if (path.startsWith('http')) return path;
    return '$imageBaseUrl$path';
  }
}
