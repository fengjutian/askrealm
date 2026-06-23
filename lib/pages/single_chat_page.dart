import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';

/// 单人对话页（1v1）
class SingleChatPage extends StatefulWidget {
  const SingleChatPage({super.key});

  @override
  State<SingleChatPage> createState() => _SingleChatPageState();
}

class _SingleChatPageState extends State<SingleChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _lastMessageCount = context.read<ChatProvider>().messages.length;
    context.read<ChatProvider>().addListener(_onChatUpdate);
  }

  @override
  void dispose() {
    context.read<ChatProvider>().removeListener(_onChatUpdate);
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _onChatUpdate() {
    final chat = context.read<ChatProvider>();
    if (chat.messages.length > _lastMessageCount) {
      _lastMessageCount = chat.messages.length;
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<bool> _confirmClear(BuildContext context, ChatProvider chat) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('清空对话？'),
        content: const Text('所有消息将被删除，无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red[300]),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (result == true) {
      chat.clearMessages();
    }
    return result ?? false;
  }

  void _sendMessage(ChatProvider chat) {
    final text = _inputController.text.trim();
    if (text.isEmpty || !chat.canSend) return;
    chat.sendMessage(text);
    _inputController.clear();
    _scrollToBottom();
  }

  void _switchCharacter(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/select', arguments: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        final character = chat.currentCharacter;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            ),
            title: character != null
                ? Row(
                    children: [
                      Text(character.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            character.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            character.from,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : const Text('对话'),
            actions: [
              if (chat.hasMessages)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmClear(context, chat),
                  tooltip: '清空对话',
                ),
              // 切换角色
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                onPressed: () => _switchCharacter(context),
                tooltip: '切换角色',
              ),
            ],
          ),
          body: character == null
              ? const Center(child: Text('请先选择角色'))
              : Column(
                  children: [
                    Expanded(
                      child: chat.messages.isEmpty
                          ? _buildEmptyState(theme, character)
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: chat.messages.length,
                              itemBuilder: (context, index) {
                                final msg = chat.messages[index];
                                return ChatBubble(
                                  message: msg,
                                  isUser: msg.role == 'user',
                                  characterColor: character.labelColor,
                                );
                              },
                            ),
                    ),
                    _buildInputBar(context, chat),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, Character character) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(character.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              '和 ${character.name} 开始对话吧',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '💬 "${character.sampleLine}"',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, ChatProvider chat) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _inputController,
                textInputAction: TextInputAction.send,
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: '输入你的问题…',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(chat),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: chat.canSend
                ? const Color(0xFF1E88E5)
                : Colors.grey[800],
            child: IconButton(
              icon: const Icon(Icons.send, size: 18),
              color: Colors.white,
              onPressed: () => _sendMessage(chat),
            ),
          ),
        ],
      ),
    );
  }
}
