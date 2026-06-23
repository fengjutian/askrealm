import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/characters.dart';
import '../models/character.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/chat_bubble.dart';

/// 单人对话页（1v1）
class SingleChatPage extends StatelessWidget {
  const SingleChatPage({super.key});

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
                  onPressed: chat.clearMessages,
                  tooltip: '清空对话',
                ),
            ],
          ),
          body: character == null
              ? const Center(child: Text('请先选择角色'))
              : Column(
                  children: [
                    // 消息列表
                    Expanded(
                      child: chat.messages.isEmpty
                          ? _buildEmptyState(theme, character)
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: chat.messages.length,
                              itemBuilder: (context, index) {
                                final msg = chat.messages[index];
                                return ChatBubble(
                                  message: msg,
                                  isUser: msg.role == 'user',
                                );
                              },
                            ),
                    ),

                    // 输入区
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
                  hintText: '输入你的问题…',
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
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
