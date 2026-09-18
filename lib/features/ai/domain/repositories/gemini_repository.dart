import 'package:cinemax_app/features/ai/domain/entities/chat_message.dart';

abstract class GeminiRepository {
  Stream<String> streamMessage({
    required List<ChatMessage> history,
    required String message,
  });
}
