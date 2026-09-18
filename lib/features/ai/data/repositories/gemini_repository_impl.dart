import 'package:cinemax_app/features/ai/data/api/gemini_api.dart';
import 'package:cinemax_app/features/ai/data/services/movie_context_enricher.dart';
import 'package:cinemax_app/features/ai/domain/entities/chat_message.dart';
import 'package:cinemax_app/features/ai/domain/repositories/gemini_repository.dart';

class GeminiRepositoryImpl implements GeminiRepository {
  final GeminiApi _api;
  final MovieContextEnricher _movieContextEnricher;

  GeminiRepositoryImpl({
    GeminiApi? api,
    MovieContextEnricher? movieContextEnricher,
  }) : _api = api ?? GeminiApi(),
       _movieContextEnricher = movieContextEnricher ?? MovieContextEnricher();

  @override
  Stream<String> streamMessage({
    required List<ChatMessage> history,
    required String message,
  }) async* {
    // Enrich prompt with TMDB movie details if applicable
    final enrichedInput = await _movieContextEnricher.enrichInput(message);

    // Limit conversation history to last 10 messages (5 turns) to stay within context windows
    final trimmedHistory = history.length > 10
        ? history.sublist(history.length - 10)
        : history;

    yield* _api.streamChatCompletion(
      history: trimmedHistory,
      userPrompt: enrichedInput,
    );
  }
}
