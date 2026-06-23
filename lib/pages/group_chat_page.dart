import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';

/// 多人聊天室页（1vN）
class GroupChatPage extends StatelessWidget {
  const GroupChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
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
                // 显示所有成员小头像
                ...chat.roomCharacters.take(4).map((c) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: c.labelColor.withOpacity(0.3),
                        child: Text(c.emoji, style: const TextStyle(fontSize: 16)),
                      ),
                    )),
                const SizedBox(width: 8),
                const Text('聊天室'),
              ],
            ),
            actions: [
              if (chat.hasMessages)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: chat.clearMessages,
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

              const Divider(height: 1, color: Colors.white12),

              // 消息列表
              Expanded(
                child: chat.messages.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: chat.messages.length +
                            chat.loadingCharacterIds.length,
                        itemBuilder: (context, index) {
                          if (index < chat.messages.length) {
                            final msg = chat.messages[index];
                            return ChatBubble(
                              message: msg,
                              isUser: msg.role == 'user',
                            );
                          }
                          // 加载中的占位
                          return const SizedBox.shrink();
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
    final controller = TextEditingController();

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
                controller: controller,
                textInputAction: TextInputAction.send,
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: '问大家一个问题…',
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty && chat.canSend) {
                    chat.sendMessage(value);
                    controller.clear();
                  }
                },
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
              onPressed: chat.canSend
                  ? () {
                      if (controller.text.trim().isNotEmpty) {
                        chat.sendMessage(controller.text);
                        controller.clear();
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
