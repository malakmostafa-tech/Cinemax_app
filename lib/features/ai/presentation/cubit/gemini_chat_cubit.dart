import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/features/ai/data/api/gemini_api.dart';
import 'package:cinemax_app/features/ai/domain/entities/chat_message.dart';
import 'package:cinemax_app/features/ai/domain/repositories/gemini_repository.dart';
import 'package:cinemax_app/features/ai/presentation/cubit/gemini_chat_state.dart';

class GeminiChatCubit extends Cubit<GeminiChatState> {
  final GeminiRepository _repository;
  StreamSubscription<String>? _streamSubscription;

  GeminiChatCubit(this._repository) : super(const GeminiChatState());

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }

  void clearError() {
    if (state.errorMessage == null) return;
    emit(state.copyWith(clearError: true));
  }

  void clearChat() {
    _streamSubscription?.cancel();
    emit(const GeminiChatState());
  }

  Future<void> retryLastMessage() async {
    final prompt = state.lastFailedPrompt;
    if (prompt != null && prompt.isNotEmpty) {
      emit(state.copyWith(clearFailedPrompt: true, clearError: true));
      await sendMessage(prompt);
    }
  }

  Future<void> sendMessage(String rawMessage) async {
    final message = rawMessage.trim();
    if (message.isEmpty) {
      emit(state.copyWith(errorMessage: 'Please enter a message.'));
      return;
    }

    if (state.isSending) return;

    if (GeminiApi.apiKey.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Gemini API Key is missing. Please add GEMINI_API_KEY to your .env file.',
        lastFailedPrompt: message,
      ));
      return;
    }

    final userMessage = ChatMessage.user(message);
    final historyBeforeMessage = List<ChatMessage>.from(state.messages);
    final updatedMessages = [...historyBeforeMessage, userMessage];

    // Placeholder assistant message for streaming chunks
    final assistantMsgId = DateTime.now().microsecondsSinceEpoch.toString();
    final assistantMessage = ChatMessage.assistant('', id: assistantMsgId, isStreaming: true);

    emit(state.copyWith(
      messages: [...updatedMessages, assistantMessage],
      isSending: true,
      clearError: true,
      clearFailedPrompt: true,
    ));

    StringBuffer textBuffer = StringBuffer();

    try {
      await _streamSubscription?.cancel();

      final stream = _repository.streamMessage(
        history: historyBeforeMessage,
        message: message,
      );

      final completer = Completer<void>();

      _streamSubscription = stream.listen(
        (chunk) {
          textBuffer.write(chunk);
          final currentList = List<ChatMessage>.from(state.messages);
          final index = currentList.indexWhere((m) => m.id == assistantMsgId);
          if (index != -1) {
            currentList[index] = currentList[index].copyWith(
              text: textBuffer.toString(),
              isStreaming: true,
            );
            emit(state.copyWith(messages: currentList));
          }
        },
        onError: (dynamic error) {
          final errorMsg = _mapErrorToUserMessage(error);
          _handleStreamError(assistantMsgId, errorMsg, message);
          if (!completer.isCompleted) completer.complete();
        },
        onDone: () {
          final currentList = List<ChatMessage>.from(state.messages);
          final index = currentList.indexWhere((m) => m.id == assistantMsgId);
          if (index != -1) {
            currentList[index] = currentList[index].copyWith(
              text: textBuffer.toString(),
              isStreaming: false,
            );
          }
          emit(state.copyWith(
            messages: currentList,
            isSending: false,
          ));
          if (!completer.isCompleted) completer.complete();
        },
        cancelOnError: true,
      );

      await completer.future;
    } catch (e) {
      _handleStreamError(assistantMsgId, _mapErrorToUserMessage(e), message);
    }
  }

  void _handleStreamError(String assistantMsgId, String errorMessage, String prompt) {
    final currentList = List<ChatMessage>.from(state.messages);
    final index = currentList.indexWhere((m) => m.id == assistantMsgId);
    if (index != -1) {
      if (currentList[index].text.isEmpty) {
        // Remove empty assistant placeholder if no text was streamed before error
        currentList.removeAt(index);
      } else {
        currentList[index] = currentList[index].copyWith(
          isStreaming: false,
          isError: true,
        );
      }
    }

    emit(state.copyWith(
      messages: currentList,
      isSending: false,
      errorMessage: errorMessage,
      lastFailedPrompt: prompt,
    ));
  }

  String _mapErrorToUserMessage(dynamic error) {
    if (error is GeminiException) {
      return error.message;
    }
    final str = error.toString().toLowerCase();
    if (str.contains('network') || str.contains('socket') || str.contains('connection')) {
      return 'Network connection lost. Please check your internet connection.';
    }
    if (str.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    return 'An unexpected error occurred while communicating with Gemini. Please try again.';
  }
}
