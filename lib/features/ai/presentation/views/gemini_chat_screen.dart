import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/features/movie/data/movie_repository.dart';
import 'package:cinemax_app/services/tmdb_service.dart';
import 'package:cinemax_app/features/ai/data/api/gemini_api.dart';
import 'package:cinemax_app/features/ai/data/repositories/gemini_repository_impl.dart';
import 'package:cinemax_app/features/ai/data/services/movie_context_enricher.dart';
import 'package:cinemax_app/features/ai/domain/entities/chat_message.dart';
import 'package:cinemax_app/features/ai/presentation/cubit/gemini_chat_cubit.dart';
import 'package:cinemax_app/features/ai/presentation/cubit/gemini_chat_state.dart';
import 'package:cinemax_app/features/ai/presentation/widgets/chat_input_bar.dart';
import 'package:cinemax_app/features/ai/presentation/widgets/chat_message_bubble.dart';

class GeminiChatScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const GeminiChatScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    // Instantiate MovieRepository using environment/default TMDBService if available
    final tmdbService = TMDBService(
      apiKey: '3c6a284e154df432b7539c529d171b03',
      sessionId: 'dd9cd7a9336f6926c70ed835dd51752a0ca540e5',
      accountId: '23708564',
    );
    final movieRepo = MovieRepository(tmdbService);
    final enricher = MovieContextEnricher(movieRepo);
    final geminiRepo = GeminiRepositoryImpl(
      api: GeminiApi(),
      movieContextEnricher: enricher,
    );

    return BlocProvider(
      create: (_) => GeminiChatCubit(geminiRepo),
      child: _GeminiChatView(onBack: onBack),
    );
  }
}

class _GeminiChatView extends StatefulWidget {
  final VoidCallback? onBack;
  const _GeminiChatView({this.onBack});

  @override
  State<_GeminiChatView> createState() => _GeminiChatViewState();
}

class _GeminiChatViewState extends State<_GeminiChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;

    context.read<GeminiChatCubit>().sendMessage(text);
    _controller.clear();
    if (_isEditing) {
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _onEditMessage(ChatMessage message) {
    setState(() {
      _isEditing = true;
      _controller.text = message.text;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
    _focusNode.requestFocus();
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocConsumer<GeminiChatCubit, GeminiChatState>(
          listenWhen: (previous, current) =>
              previous.messages.length != current.messages.length ||
              previous.messages.fold(0, (acc, m) => acc + m.text.length) !=
                  current.messages.fold(0, (acc, m) => acc + m.text.length) ||
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            _scrollToBottom();
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary, size: 20),
                        onPressed: widget.onBack ??
                            () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                size: 18,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cinemax AI',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Powered by Gemini',
                                  style: GoogleFonts.inter(
                                    color: AppColors.secondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (state.messages.isNotEmpty)
                        IconButton(
                          tooltip: 'Clear Chat',
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.textSecondary, size: 22),
                          onPressed: () {
                            context.read<GeminiChatCubit>().clearChat();
                          },
                        ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.divider, height: 1),

                // Error Message Card
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF381D23),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 18,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              state.errorMessage!,
                              style: GoogleFonts.inter(
                                color: AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (state.lastFailedPrompt != null)
                            TextButton(
                              onPressed: () {
                                context
                                    .read<GeminiChatCubit>()
                                    .retryLastMessage();
                              },
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Retry',
                                style: GoogleFonts.inter(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  size: 16, color: AppColors.error),
                              onPressed: () {
                                context.read<GeminiChatCubit>().clearError();
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ),
                  ),

                // Main Chat Body
                Expanded(
                  child: state.messages.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.surface,
                                    border: Border.all(
                                      color: AppColors.secondary.withValues(alpha: 0.4),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.secondary
                                            .withValues(alpha: 0.2),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.auto_awesome,
                                      size: 32,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Welcome to Cinemax AI',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Ask me for movie recommendations, plot breakdowns, actors, genres, or what to watch tonight!',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    _buildPromptChip(
                                        '🎬 Top sci-fi movies of all time'),
                                    _buildPromptChip(
                                        '🍿 Recommend a high-stakes thriller'),
                                    _buildPromptChip(
                                        '⭐ Explain the ending of Inception'),
                                    _buildPromptChip(
                                        'اقترح لي أفضل أفلام سينمائية ممتعة'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            return ChatMessageBubble(
                              message: message,
                              onEdit: message.isUser
                                  ? () => _onEditMessage(message)
                                  : null,
                            );
                          },
                        ),
                ),

                // Chat Input Bar
                ChatInputBar(
                  controller: _controller,
                  focusNode: _focusNode,
                  onSend: _sendMessage,
                  isSending: state.isSending,
                  isEditing: _isEditing,
                  onCancelEdit: _cancelEdit,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPromptChip(String prompt) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _controller.text = prompt;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: prompt.length),
          );
          _focusNode.requestFocus();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Text(
            prompt,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
