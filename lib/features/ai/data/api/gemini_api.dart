import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:cinemax_app/features/ai/domain/entities/chat_message.dart';
import 'package:cinemax_app/features/ai/domain/constants/movie_assistant_prompt.dart';

/// Exception classes for structured Gemini error handling.
abstract class GeminiException implements Exception {
  final String message;
  const GeminiException(this.message);

  @override
  String toString() => message;
}

class GeminiApiKeyMissingException extends GeminiException {
  const GeminiApiKeyMissingException()
      : super('Gemini API key is missing. Please set GEMINI_API_KEY in your .env file.');
}

class GeminiInvalidKeyException extends GeminiException {
  const GeminiInvalidKeyException()
      : super('Invalid API key. Please check your GEMINI_API_KEY in your .env file.');
}

class GeminiRateLimitException extends GeminiException {
  const GeminiRateLimitException()
      : super('Rate limit exceeded. Please wait a moment before sending another message.');
}

class GeminiNetworkException extends GeminiException {
  const GeminiNetworkException([super.message = 'Network connection failed or request timed out. Please check your internet connection.']);
}

class GeminiServerException extends GeminiException {
  final int statusCode;
  const GeminiServerException(this.statusCode, [super.message = 'Gemini service is temporarily unavailable. Please try again later.']);
}

class GeminiBlockedException extends GeminiException {
  const GeminiBlockedException([super.message = 'The response was blocked by safety filters.']);
}

class GeminiEmptyResponseException extends GeminiException {
  const GeminiEmptyResponseException()
      : super('Received an empty response from Gemini. Please try asking again.');
}

class GeminiApi {
  static const String model = 'gemini-3.6-flash';
  static const String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$model';
  static const Duration requestTimeout = Duration(seconds: 35);
  static const int maxRetries = 3;

  final http.Client _client;

  GeminiApi({http.Client? client}) : _client = client ?? http.Client();

  /// Reads GEMINI_API_KEY from dotenv or system environment.
  static String get apiKey {
    final key = dotenv.env['GEMINI_API_KEY'] ??
        Platform.environment['GEMINI_API_KEY'] ??
        '';
    return key.trim();
  }

  /// Streaming completion API yielding real-time text chunks.
  Stream<String> streamChatCompletion({
    required List<ChatMessage> history,
    required String userPrompt,
    String? systemInstruction,
  }) async* {
    final key = apiKey;
    if (key.isEmpty) {
      throw const GeminiApiKeyMissingException();
    }

    final contents = history
        .map((m) => m.toGeminiContent())
        .toList();

    contents.add({
      'role': 'user',
      'parts': [
        {'text': userPrompt}
      ],
    });

    final bodyMap = <String, dynamic>{
      'contents': contents,
      'system_instruction': {
        'parts': [
          {'text': systemInstruction ?? MovieAssistantPrompt.systemInstruction}
        ]
      },
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 2048,
      },
    };

    final uri = Uri.parse('$baseUrl:streamGenerateContent?alt=sse&key=$key');

    http.StreamedResponse? streamedResponse;
    int retryCount = 0;
    Duration retryDelay = const Duration(seconds: 1);

    while (true) {
      try {
        final request = http.Request('POST', uri)
          ..headers['Content-Type'] = 'application/json'
          ..body = jsonEncode(bodyMap);

        streamedResponse = await _client.send(request).timeout(requestTimeout);

        if (streamedResponse.statusCode == 200) {
          break; // Success
        }

        final responseBody = await streamedResponse.stream.bytesToString();

        if (streamedResponse.statusCode == 401 || streamedResponse.statusCode == 403) {
          throw const GeminiInvalidKeyException();
        }

        if ((streamedResponse.statusCode == 429 || streamedResponse.statusCode >= 500) &&
            retryCount < maxRetries) {
          retryCount++;
          await Future.delayed(retryDelay);
          retryDelay *= 2; // Exponential backoff: 1s, 2s, 4s
          continue;
        }

        if (streamedResponse.statusCode == 429) {
          throw const GeminiRateLimitException();
        }

        if (streamedResponse.statusCode >= 500) {
          throw GeminiServerException(streamedResponse.statusCode);
        }

        String userMessage = 'Gemini error (${streamedResponse.statusCode})';
        try {
          final errJson = jsonDecode(responseBody);
          if (errJson is Map && errJson['error'] is Map && errJson['error']['message'] != null) {
            userMessage = errJson['error']['message'].toString();
          } else {
            userMessage = responseBody;
          }
        } catch (_) {
          userMessage = responseBody;
        }

        throw GeminiServerException(
          streamedResponse.statusCode,
          userMessage,
        );
      } on SocketException catch (_) {
        throw const GeminiNetworkException();
      } on TimeoutException catch (_) {
        if (retryCount < maxRetries) {
          retryCount++;
          await Future.delayed(retryDelay);
          retryDelay *= 2;
          continue;
        }
        throw const GeminiNetworkException('Connection timed out. Please try again.');
      } catch (e) {
        if (e is GeminiException) rethrow;
        throw GeminiNetworkException('Unexpected network error: ${e.toString()}');
      }
    }

    bool receivedAnyText = false;

    await for (final line in streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      final trimmedLine = line.trim();
      if (!trimmedLine.startsWith('data:')) continue;

      final dataStr = trimmedLine.substring(5).trim();
      if (dataStr.isEmpty || dataStr == '[DONE]') continue;

      try {
        final json = jsonDecode(dataStr);
        if (json is! Map<String, dynamic>) continue;

        final candidates = json['candidates'];
        if (candidates is List && candidates.isNotEmpty) {
          final first = candidates[0];
          if (first is Map<String, dynamic>) {
            final finishReason = first['finishReason']?.toString();
            if (finishReason == 'SAFETY' || finishReason == 'RECITATION') {
              throw const GeminiBlockedException();
            }

            final content = first['content'];
            if (content is Map<String, dynamic>) {
              final parts = content['parts'];
              if (parts is List && parts.isNotEmpty) {
                for (final part in parts) {
                  if (part is Map<String, dynamic> && part.containsKey('text')) {
                    final text = part['text']?.toString();
                    if (text != null && text.isNotEmpty) {
                      receivedAnyText = true;
                      yield text;
                    }
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        if (e is GeminiBlockedException) rethrow;
        // Ignore parse errors on individual SSE chunks
      }
    }

    if (!receivedAnyText) {
      throw const GeminiEmptyResponseException();
    }
  }
}
