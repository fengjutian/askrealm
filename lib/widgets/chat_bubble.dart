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
      return _buildUserBubble(isDark);
    } else {
      return _buildAssistantBubble(isDark);
    }
  }

  /// 用户消息气泡（靠右）
  Widget _buildUserBubble(bool isDark) {
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

  /// 角色消息气泡（靠左）— 基于已验证可工作的结构
  Widget _buildAssistantBubble(bool isDark) {
    final color = characterColor ?? warmGrey;

    return Container(
      margin: const EdgeInsets.only(right: 60, bottom: 8),
      padding: const EdgeInsets.all(12),
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
          top: BorderSide(color: noirDivider.withOpacity(0.4)),
          right: BorderSide(color: noirDivider.withOpacity(0.4)),
          bottom: BorderSide(color: noirDivider.withOpacity(0.4)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? noirCard : Colors.white,
              border: Border.all(color: color.withOpacity(0.45), width: 1.2),
            ),
            child: Center(
              child: Text(
                message.characterEmoji ?? '🤖',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          // 气泡内容
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 角色名
              if (message.characterName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    message.characterName!,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              // 状态描述
              Text(
                _statusText,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? warmGrey : const Color(0xFF8B8378),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 4),
              // 正文或加载动画
              if (message.isLoading && message.content.isEmpty)
                _LoadingDots(color: color)
              else
                Text(
                  message.content.isEmpty ? '[空]' : message.content,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? warmWhite : Colors.black87,
                    height: 1.5,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String get _statusText {
    final loading = message.isLoading ? '加载中' : '已完成';
    return '角色:${message.characterId ?? "?"} | 状态:$loading | 长度:${message.content.length}';
  }
}

/// ─── 加载跳动圆点 ──────────────────────────────────────────────────
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
            final opacity =
                0.25 + 0.75 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2);
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
