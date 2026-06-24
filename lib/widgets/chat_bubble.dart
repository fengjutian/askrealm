import 'package:flutter/material.dart';
import '../models/message.dart';
import '../theme.dart';

/// 聊天气泡组件 — 脚本页风格（Noir Cinema）
class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isUser;
  final Color? characterColor;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.characterColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isUser) {
      return _buildUserBubble(context, isDark);
    } else {
      return _buildAssistantBubble(context, isDark);
    }
  }

  /// 用户消息气泡（靠右）— 暖金底色，像导演批注
  Widget _buildUserBubble(BuildContext context, bool isDark) {
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
                color: isDark
                    ? spotlightGold.withOpacity(0.14)
                    : const Color(0xFFF5ECDA),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(6),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(
                  color: spotlightGold.withOpacity(isDark ? 0.2 : 0.35),
                  width: 0.8,
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? warmWhite : const Color(0xFF2A2218),
                  letterSpacing: 0.3,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  /// 角色消息气泡（靠左）— 卡片底 + 角色色左边条 + 头像金色环
  Widget _buildAssistantBubble(BuildContext context, bool isDark) {
    final color = characterColor ?? warmGrey;

    return Padding(
      padding: const EdgeInsets.only(right: 60, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 角色头像 — 金色细环
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? noirCard : Colors.white,
                border: Border.all(
                  color: color.withOpacity(0.45),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  message.characterEmoji ?? '🤖',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 角色名标签 — 角色色
                if (message.characterName != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      message.characterName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                // 气泡内容
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? noirCard : const Color(0xFFF8F4EC),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    border: Border(
                      left: BorderSide(color: color.withOpacity(0.55), width: 3),
                      top: BorderSide(color: isDark ? noirDivider.withOpacity(0.4) : const Color(0xFFD5CFC4)),
                      right: BorderSide(color: isDark ? noirDivider.withOpacity(0.4) : const Color(0xFFD5CFC4)),
                      bottom: BorderSide(color: isDark ? noirDivider.withOpacity(0.4) : const Color(0xFFD5CFC4)),
                    ),
                  ),
                  child: message.isLoading && message.content.isEmpty
                      ? _buildLoadingIndicator(isDark, color)
                      : _buildContent(context, isDark, color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, Color color) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color
        ?? (isDark ? warmWhite : const Color(0xFF1A1A1A));

    // 加载完成但内容为空 — 说明 API 返回了空响应
    if (!message.isLoading && message.content.isEmpty) {
      return Text(
        '（暂无回复，请检查 API 配置或重试）',
        style: TextStyle(
          fontSize: 13,
          color: isDark ? warmGrey : const Color(0xFF9B8E7A),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (!message.isLoading) {
      return Text(
        message.content,
        style: TextStyle(
          fontSize: 15,
          color: textColor,
          letterSpacing: 0.3,
          height: 1.5,
        ),
      );
    }

    // 流式加载中 — 金色闪烁光标
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            message.content,
            style: TextStyle(
              fontSize: 15,
              color: textColor,
              letterSpacing: 0.3,
              height: 1.5,
            ),
          ),
        ),
        const _StreamingCursor(),
      ],
    );
  }

  Widget _buildLoadingIndicator(bool isDark, Color color) {
    return _LoadingDots(color: color);
  }
}

/// ─── 流式输出金色闪烁光标 ───────────────────────────────────────────
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
    return FadeTransition(
      opacity: _controller,
      child: const Padding(
        padding: EdgeInsets.only(left: 1),
        child: Text(
          '▊',
          style: TextStyle(fontSize: 14, color: spotlightGold),
        ),
      ),
    );
  }
}

/// ─── 加载跳动圆点 — 金色 ────────────────────────────────────────────
class _LoadingDots extends StatefulWidget {
  final Color color;
  const _LoadingDots({required this.color});

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
            final opacity = 0.25 + 0.75 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2);
            return Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(opacity),
              ),
            );
          },
        );
      }),
    );
  }
}
