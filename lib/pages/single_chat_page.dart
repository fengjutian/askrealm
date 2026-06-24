import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../providers/chat_provider.dart';
import '../theme.dart';
import '../widgets/chat_bubble.dart';

/// 单人对话页（1v1） — 脚本式聊天
class SingleChatPage extends StatefulWidget {
  const SingleChatPage({super.key});

  @override
  State<SingleChatPage> createState() => _SingleChatPageState();
}

class _SingleChatPageState extends State<SingleChatPage> {
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

  void _switchCharacter(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/select', arguments: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        final character = chat.currentCharacter;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: warmGrey,
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            ),
            title: character != null
                ? Row(
                    children: [
                      // 角色 Emoji 加金色细环
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: spotlightGold.withOpacity(0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(character.emoji, style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            character.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? warmWhite : null,
                            ),
                          ),
                          Text(
                            character.from,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? warmGrey : const Color(0xFF8B8378),
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
                  icon: Icon(Icons.delete_outline, color: warmGrey.withOpacity(0.7)),
                  onPressed: () => _confirmClear(context, chat),
                  tooltip: '清空对话',
                ),
              IconButton(
                icon: Icon(Icons.swap_horiz, color: warmGrey.withOpacity(0.7)),
                onPressed: () => _switchCharacter(context),
                tooltip: '切换角色',
              ),
            ],
          ),
          body: character == null
              ? const Center(child: Text('请先选择角色'))
              : Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: chat.messages.isEmpty
                              ? _buildEmptyState(theme, isDark, character)
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

  Widget _buildEmptyState(ThemeData theme, bool isDark, Character character) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 角色 Emoji + 金色聚光背景
            Stack(
              alignment: Alignment.center,
              children: [
                if (isDark)
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(painter: _SpotlightPainter()),
                  ),
                Text(character.emoji, style: const TextStyle(fontSize: 64)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '和 ${character.name} 开始对话吧',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? warmWhite : null,
              ),
            ),
            const SizedBox(height: 12),
            // 台词引用 — 帷幕红左边条
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? noirCard : const Color(0xFFF8F4EC),
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(color: curtainRed.withOpacity(0.5), width: 3),
                ),
              ),
              child: Text(
                '"${character.sampleLine}"',
                style: TextStyle(
                  color: isDark ? warmGrey : const Color(0xFF8B8378),
                  fontSize: 13,
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

  Widget _buildInputBar(BuildContext context, ChatProvider chat, bool isDark) {
    final borderColor = _inputFocused ? spotlightGold : noirDivider;
    final bgColor = _inputFocused ? noirCard : noirCard;

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
                color: bgColor,
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
                  hintText: '输入你的问题…',
                  hintStyle: TextStyle(color: warmGrey.withOpacity(0.6)),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(chat),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 金色发送按钮
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
