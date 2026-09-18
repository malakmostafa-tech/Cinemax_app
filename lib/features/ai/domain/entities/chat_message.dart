enum ChatMessageRole { user, model }

class ChatMessage {
  final String id;
  final ChatMessageRole role;
  final String text;
  final bool isStreaming;
  final bool isError;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    this.isStreaming = false,
    this.isError = false,
  });

  factory ChatMessage.user(String text, {String? id}) {
    return ChatMessage(
      id: id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      role: ChatMessageRole.user,
      text: text,
    );
  }

  factory ChatMessage.assistant(String text, {String? id, bool isStreaming = false, bool isError = false}) {
    return ChatMessage(
      id: id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      role: ChatMessageRole.model,
      text: text,
      isStreaming: isStreaming,
      isError: isError,
    );
  }

  bool get isUser => role == ChatMessageRole.user;

  ChatMessage copyWith({
    String? id,
    ChatMessageRole? role,
    String? text,
    bool? isStreaming,
    bool? isError,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      text: text ?? this.text,
      isStreaming: isStreaming ?? this.isStreaming,
      isError: isError ?? this.isError,
    );
  }

  Map<String, dynamic> toGeminiContent() {
    return {
      'role': role == ChatMessageRole.user ? 'user' : 'model',
      'parts': [
        {'text': text}
      ],
    };
  }
}
