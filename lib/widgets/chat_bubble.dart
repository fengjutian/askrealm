import 'package:flutter/material.dart';
import '../models/message.dart';

/// 聊天气泡组件
class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isUser;
  final Color? characterColor; // 角色标签色

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.characterColor,
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
    final isLight = theme.brightness == Brightness.light;
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
                color: isLight
                    ? const Color(0xFF1E88E5).withOpacity(0.85)
                    : const Color(0xFF1E88E5).withOpacity(0.3),
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
    final isLight = theme.brightness == Brightness.light;
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
              backgroundColor: isLight ? Colors.grey[200] : Colors.white12,
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
                        color: characterColor ?? Colors.grey[400],
                        fontWeight: FontWeight.w600,
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
                    border: Border(
                      left: BorderSide(
                        color: characterColor?.withOpacity(0.6) ?? theme.dividerColor,
                        width: 3,
                      ),
                    ),
                  ),
                  child: message.isLoading && message.content.isEmpty
                      ? _buildLoadingIndicator(theme)
                      : _buildContent(theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final isLight = theme.brightness == Brightness.light;
    final textColor = isLight ? Colors.black87 : Colors.white.withOpacity(0.9);

    if (!message.isLoading) {
      return Text(
        message.content,
        style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
      );
    }

    // 流式加载中 — 内容末尾加闪烁光标
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            message.content,
            style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
          ),
        ),
        const _StreamingCursor(),
      ],
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    return _LoadingDots(isLight: theme.brightness == Brightness.light);
  }
}

/// 流式输出时的闪烁光标
class _StreamingCursor extends StatefulWidget {
  const _StreamingCursor();

  @override
  State<_StreamingCursor> createState() => _StreamingCursorState();
}

class _StreamingCursorState extends State<_StreamingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return FadeTransition(
      opacity: _controller,
      child: Padding(
        padding: const EdgeInsets.only(left: 1),
        child: Text(
          '▊',
          style: TextStyle(
            fontSize: 14,
            color: isLight ? Colors.black54 : Colors.white60,
          ),
        ),
      ),
    );
  }
}
/// 循环闪烁的加载点动画组件
class _LoadingDots extends StatefulWidget {
  final bool isLight;
  const _LoadingDots({required this.isLight});

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final phase = (_controller.value * 3 + i) % 1.0;
            final opacity = 0.3 + 0.7 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2);
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isLight
                    ? Colors.black.withOpacity(opacity * 0.5)
                    : Colors.white.withOpacity(opacity),
              ),
            );
          },
        );
      }),
    );
  }
}
