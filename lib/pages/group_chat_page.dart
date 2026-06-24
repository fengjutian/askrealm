import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../providers/chat_provider.dart';
import '../theme.dart';
import '../widgets/chat_bubble.dart';

/// 多人聊天室页（1vN） — Noir Cinema 风格
class GroupChatPage extends StatefulWidget {
  const GroupChatPage({super.key});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  int _lastMessageCount = 0;
  bool _userScrolledUp = false;
  bool _inputFocused = false;
  late final ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();
    _lastMessageCount = _chatProvider.messages.length;
    _chatProvider.addListener(_onChatUpdate);
    _scrollController.addListener(_onScroll);
    _inputFocus.addListener(() {
      setState(() => _inputFocused = _inputFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _chatProvider.removeListener(_onChatUpdate);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _inputController.dispose();
    _inputFocus.removeListener(() {});
    _inputFocus.dispose();
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
    if (chars.every((c) => c.from.contains('狂飙'))) return '⚡ 京海风云录';
    final names = chars.map((c) => c.name).join('、');
    return '📢 $names';
  }

  Future<bool> _confirmClear(BuildContext context, ChatProvider chat) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).dialogTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('清空对话？'),
        content: const Text('所有消息将被删除，无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: curtainRed),
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
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
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
              color: warmGrey,
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            ),
            title: Row(
              children: [
                // 成员小头像 — 各自角色色细环
                ...chat.roomCharacters.take(4).map((c) => Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? noirCard : Colors.white,
                          border: Border.all(
                            color: c.labelColor.withOpacity(0.5),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(c.emoji, style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                    )),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _roomName(chat.roomCharacters),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? warmWhite : null,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              if (chat.hasMessages)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: warmGrey.withOpacity(0.7)),
                  onPressed: () => _confirmClear(context, chat),
                  tooltip: '清空对话',
                ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  // 成员标签行 — 加深芯片
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: chat.roomCharacters.map((c) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: c.labelColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: c.labelColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(c.emoji, style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 4),
                                Text(
                                  c.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: c.labelColor,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  Divider(height: 1, color: isDark ? noirDivider : const Color(0xFFDDD5C8)),

                  // 消息列表
                  Expanded(
                    child: chat.messages.isEmpty && chat.loadingCharacterIds.isEmpty
                        ? _buildEmptyState(theme, isDark)
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

                  // 输入指示器 — 金色 spinner
                  if (chat.loadingCharacterIds.isNotEmpty)
                    _buildTypingIndicator(isDark, chat),

                  // 输入区
                  _buildInputBar(context, chat, isDark),
                ],
              ),
              // 四角暗角
              if (isDark) vignetteOverlay(intensity: 0.45),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (isDark)
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(painter: _SpotlightPainter()),
                  ),
                const Text('👥', style: TextStyle(fontSize: 64)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '发送一个问题，看看大家怎么说',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? warmWhite : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '所有角色将依次回答',
              style: TextStyle(
                color: isDark ? warmGrey : const Color(0xFF8B8378),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark, ChatProvider chat) {
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
              color: spotlightGold.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$names 正在输入…',
            style: TextStyle(
              color: warmGrey.withOpacity(0.8),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, ChatProvider chat, bool isDark) {
    final borderColor = _inputFocused ? spotlightGold : noirDivider;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: isDark ? noirDivider : const Color(0xFFDDD5C8))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: noirCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor.withOpacity(0.5), width: 1),
              ),
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocus,
                textInputAction: TextInputAction.send,
                maxLines: 4,
                minLines: 1,
                style: TextStyle(color: isDark ? warmWhite : null),
                decoration: InputDecoration(
                  hintText: '问大家一个问题…',
                  hintStyle: TextStyle(color: warmGrey.withOpacity(0.6)),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(chat),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: chat.canSend ? spotlightGold : noirDivider,
            ),
            child: IconButton(
              icon: Icon(Icons.send, size: 18, color: chat.canSend ? noirBackground : warmGrey),
              onPressed: () => _sendMessage(chat),
            ),
          ),
        ],
      ),
    );
  }
}

/// 小尺寸金色聚光绘制器
class _SpotlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          spotlightGold.withOpacity(0.1),
          spotlightGold.withOpacity(0.02),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
