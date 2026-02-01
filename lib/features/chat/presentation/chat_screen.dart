import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/app_animation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/service_locator.dart';
import '../data/models/chat_message.dart';
import 'chat_providers.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../usage/presentation/providers/usage_providers.dart';
import '../../usage/data/services/usage_service.dart';
import '../data/services/chat_storage_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final storageService = ref.read(chatStorageServiceProvider);
      final history = await storageService.loadMessages(user.id);

      if (mounted) {
        setState(() {
          _messages.addAll(history);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _clearHistory() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final storageService = ref.read(chatStorageServiceProvider);
    await storageService.clearHistory(user.id);

    if (mounted) {
      setState(() {
        _messages.clear();
      });
    }
  }

  void _sendMessage([String? text]) async {
    final messageText = text ?? _controller.text.trim();
    if (messageText.isEmpty) return;

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    // Check usage limit
    final usageService = ref.read(usageServiceProvider);
    final currentUsage = await usageService.getTodayUsageCount('chat');

    if (currentUsage >= UsageService.dailyLimit) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Daily limit reached for Chat (10/10). Try again tomorrow!',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final userMessage = ChatMessage(
      id: DateTime.now().toIso8601String(),
      userId: user.id,
      text: messageText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
      _controller.clear();
    });

    _scrollToBottom();

    try {
      final chatService = ref.read(chatServiceProvider);

      // Increment usage in DB
      await usageService.incrementUsage('chat');
      // ref.invalidate(todayUsageProvider('chat'));

      // Save user message to storage
      final storageService = ref.read(chatStorageServiceProvider);
      await storageService.saveMessage(
        userId: user.id,
        text: messageText,
        isUser: true,
      );

      await for (final aiMessage in chatService.sendMessage(messageText)) {
        if (mounted) {
          setState(() {
            _messages.add(aiMessage);
            _isTyping = false;
          });
          _scrollToBottom();

          // Save AI response to storage
          await storageService.saveMessage(
            userId: user.id,
            text: aiMessage.text,
            isUser: false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              id: 'err',
              userId: 'system',
              text:
                  "I'm having trouble connecting. Please check your AI API key.",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final historyAsync = ref.watch(chatHistoryProvider); // Removed duplicate provider usage
    final animationsEnabled = ref.watch(animationsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'HealthMate AI',
        showLogo: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text(
                    'Are you sure you want to clear chat history?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        _clearHistory();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty && !_isTyping
                ? AppAnimation(
                    type: AnimationType.fadeIn,
                    enabled: animationsEnabled,
                    child: _buildWelcomeState(),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildTypingIndicator();
                      }
                      final message = _messages[index];
                      return AppAnimation(
                        type: AnimationType.fadeInUp,
                        enabled: animationsEnabled,
                        duration: const Duration(milliseconds: 300),
                        child: _ChatBubble(message: message),
                      );
                    },
                  ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Start a conversation!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask about symptoms, sleep, or hydration.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16, right: 80),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('...', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInputArea() {
    final usageAsync = ref.watch(todayUsageProvider('chat'));

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              usageAsync.when(
                data: (count) => Text(
                  'Daily Usage: $count/${UsageService.dailyLimit}',
                  style: TextStyle(
                    fontSize: 10,
                    color: count >= UsageService.dailyLimit
                        ? AppColors.error
                        : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!_isTyping && _messages.isEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    [
                          'How to sleep better?',
                          'Water intake tips',
                          'Symptom advice',
                        ]
                        .map(
                          (q) => Padding(
                            padding: const EdgeInsets.only(
                              right: 8,
                              bottom: 12,
                            ),
                            child: ActionChip(
                              label: Text(
                                q,
                                style: const TextStyle(fontSize: 12),
                              ),
                              onPressed: () => _sendMessage(q),
                              backgroundColor: AppColors.primary.withOpacity(
                                0.05,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  onPressed: () => _sendMessage(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser
                ? Colors.white
                : Theme.of(context).textTheme.bodyLarge?.color,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
