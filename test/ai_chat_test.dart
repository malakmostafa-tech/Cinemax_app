import 'package:flutter_test/flutter_test.dart';
import 'package:cinemax_app/features/ai/domain/entities/chat_message.dart';
import 'package:cinemax_app/features/ai/presentation/cubit/gemini_chat_cubit.dart';
import 'package:cinemax_app/features/ai/domain/repositories/gemini_repository.dart';

class MockGeminiRepository implements GeminiRepository {
  final List<String> responses;
  final bool shouldThrow;

  MockGeminiRepository({this.responses = const ['Hello! I am Cinemax AI.'], this.shouldThrow = false});

  @override
  Stream<String> streamMessage({
    required List<ChatMessage> history,
    required String message,
  }) async* {
    if (shouldThrow) {
      throw Exception('Network error simulated');
    }
    for (final chunk in responses) {
      yield chunk;
    }
  }
}

void main() {
  group('ChatMessage Entity Tests', () {
    test('ChatMessage.user creates user message correctly', () {
      final msg = ChatMessage.user('Test query');
      expect(msg.isUser, isTrue);
      expect(msg.role, equals(ChatMessageRole.user));
      expect(msg.text, equals('Test query'));
    });

    test('ChatMessage.assistant creates assistant message correctly', () {
      final msg = ChatMessage.assistant('AI response', isStreaming: true);
      expect(msg.isUser, isFalse);
      expect(msg.role, equals(ChatMessageRole.model));
      expect(msg.text, equals('AI response'));
      expect(msg.isStreaming, isTrue);
    });

    test('toGeminiContent outputs correct json format', () {
      final msg = ChatMessage.user('Hello');
      final json = msg.toGeminiContent();
      expect(json['role'], equals('user'));
      expect(json['parts'][0]['text'], equals('Hello'));
    });
  });

  group('GeminiChatCubit Tests', () {
    test('Initial state is empty', () {
      final repo = MockGeminiRepository();
      final cubit = GeminiChatCubit(repo);
      expect(cubit.state.messages, isEmpty);
      expect(cubit.state.isSending, isFalse);
      expect(cubit.state.errorMessage, isNull);
    });

    test('Empty message prompt emits validation error', () async {
      final repo = MockGeminiRepository();
      final cubit = GeminiChatCubit(repo);
      await cubit.sendMessage('   ');
      expect(cubit.state.errorMessage, contains('Please enter a message'));
    });
  });
}
