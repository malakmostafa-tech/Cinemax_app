import 'package:cinemax_app/features/ai/domain/entities/chat_message.dart';

class GeminiChatState {
  final List<ChatMessage> messages;
  final bool isSending;
  final String? errorMessage;
  final String? lastFailedPrompt;

  const GeminiChatState({
    this.messages = const [],
    this.isSending = false,
    this.errorMessage,
    this.lastFailedPrompt,
  });

  GeminiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
    String? lastFailedPrompt,
    bool clearFailedPrompt = false,
  }) {
    return GeminiChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastFailedPrompt: clearFailedPrompt ? null : (lastFailedPrompt ?? this.lastFailedPrompt),
    );
  }
}
