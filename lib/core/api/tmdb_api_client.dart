import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cinemax_app/core/config/tmdb_config.dart';

class TmdbApiException implements Exception {
  final String message;
  final int? statusCode;

  TmdbApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'TmdbApiException: $message (Status $statusCode)';
}

class TmdbApiClient {
  final http.Client _httpClient;

  TmdbApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Map<String, String> get _headers => {
        'Authorization': 'Bearer ${TmdbConfig.readAccessToken}',
        'Content-Type': 'application/json;charset=utf-8',
        'Accept': 'application/json',
      };

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('${TmdbConfig.baseUrl}$endpoint').replace(
        queryParameters: queryParameters,
      );

      final response = await _httpClient.get(uri, headers: _headers);
      return _parseResponse(response);
    } on SocketException {
      throw TmdbApiException('Network error: Please check your internet connection.');
    } catch (e) {
      if (e is TmdbApiException) rethrow;
      throw TmdbApiException('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final uri = Uri.parse('${TmdbConfig.baseUrl}$endpoint');
      final response = await _httpClient.post(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );
      return _parseResponse(response);
    } on SocketException {
      throw TmdbApiException('Network error: Please check your internet connection.');
    } catch (e) {
      if (e is TmdbApiException) rethrow;
      throw TmdbApiException('Unexpected error: $e');
    }
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    final body = response.body.isEmpty ? {} : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body is Map<String, dynamic> ? body : {'data': body};
    }

    final statusMessage = body is Map && body.containsKey('status_message')
        ? body['status_message']
        : 'Request failed with status ${response.statusCode}';

    throw TmdbApiException(statusMessage.toString(), response.statusCode);
  }
}
