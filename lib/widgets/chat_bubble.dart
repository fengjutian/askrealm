import 'package:flutter/material.dart';
import '../models/message.dart';

/// 聊天气泡组件
class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isUser) {
      return _buildUserBubble(theme);
    } else {
      return _buildAssistantBubble(theme);
    }
  }

  /// 用户消息气泡（靠右）
  Widget _buildUserBubble(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Text(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  /// 角色消息气泡（靠左，带头像和名字）
  Widget _buildAssistantBubble(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 60, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 角色头像
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white12,
              child: Text(
                message.characterEmoji ?? '🤖',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 角色名标签
                if (message.characterName != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      message.characterName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                // 气泡内容
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: message.isLoading
                      ? _buildLoadingIndicator(theme)
                      : Text(
                          message.content,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 加载中动画
  Widget _buildLoadingIndicator(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(theme, 0),
        const SizedBox(width: 4),
        _dot(theme, 200),
        const SizedBox(width: 4),
        _dot(theme, 400),
      ],
    );
  }

  Widget _dot(ThemeData theme, int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(value),
          ),
        );
      },
      onEnd: () {},
    );
  }
}
