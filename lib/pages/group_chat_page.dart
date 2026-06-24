import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';

/// 多人聊天室页（1vN）
class GroupChatPage extends StatefulWidget {
  const GroupChatPage({super.key});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  int _lastMessageCount = 0;
  bool _userScrolledUp = false;
  late final ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();
    _lastMessageCount = _chatProvider.messages.length;
    _chatProvider.addListener(_onChatUpdate);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _chatProvider.removeListener(_onChatUpdate);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    _userScrolledUp = (maxScroll - currentScroll) > 100;
  }

  void _onChatUpdate() {
    final chat = context.read<ChatProvider>();
    if (chat.messages.length > _lastMessageCount || chat.isLoading) {
      _lastMessageCount = chat.messages.length;
      if (!_userScrolledUp) {
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _roomName(List<Character> chars) {
    if (chars.isEmpty) return '聊天室';
    final names = chars.map((c) => c.name).join('、');
    if (chars.every((c) => c.from.contains('狂飙'))) return '⚡ 京海风云录';
    return '📢 $names';
  }

  Future<bool> _confirmClear(BuildContext context, ChatProvider chat) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).dialogTheme.backgroundColor,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        // 角色颜色查找表
        final colorMap = <String, Color>{};
        for (final c in chat.roomCharacters) {
          colorMap[c.id] = c.labelColor;
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            ),
            title: Row(
              children: [
                ...chat.roomCharacters.take(4).map((c) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: c.labelColor.withOpacity(0.3),
                        child: Text(c.emoji, style: const TextStyle(fontSize: 16)),
                      ),
                    )),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _roomName(chat.roomCharacters),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              if (chat.hasMessages)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmClear(context, chat),
                  tooltip: '清空对话',
                ),
            ],
          ),
          body: Column(
            children: [
              // 成员标签行
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: chat.roomCharacters.map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: c.labelColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: c.labelColor.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(c.emoji, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              c.name,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: c.labelColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              Divider(height: 1, color: theme.dividerColor),

              // 消息列表
              Expanded(
                child: chat.messages.isEmpty && chat.loadingCharacterIds.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: chat.messages.length,
                        itemBuilder: (context, index) {
                          final msg = chat.messages[index];
                          final color = msg.characterId != null
                              ? colorMap[msg.characterId]
                              : null;
                          return ChatBubble(
                            message: msg,
                            isUser: msg.role == 'user',
                            characterColor: color,
                          );
                        },
                      ),
              ),

              // 输入指示器
              if (chat.loadingCharacterIds.isNotEmpty)
                _buildTypingIndicator(theme, chat),

              // 输入区
              _buildInputBar(context, chat),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👥', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              '发送一个问题，看看大家怎么说',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '所有角色将依次回答',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme, ChatProvider chat) {
    final names = chat.loadingCharacterIds
        .map((id) => chat.roomCharacters
            .where((c) => c.id == id)
            .map((c) => '${c.emoji} ${c.name}')
            .firstOrNull ?? '')
        .join('、');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$names 正在输入…',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, ChatProvider chat) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
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
                  hintText: '问大家一个问题…',
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
