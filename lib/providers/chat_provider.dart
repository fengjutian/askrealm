import 'package:flutter/foundation.dart';
import '../models/character.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// 对话状态管理
class ChatProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  ChatMode _mode = ChatMode.single;
  Character? _currentCharacter;
  List<Character> _roomCharacters = [];
  bool _isLoading = false;

  // 加载中的角色 id 列表
  final Set<String> _loadingCharacterIds = {};

  // 清空计数器 — 每次 clear 自增，用于检测请求是否已过时
  int _clearCount = 0;

  // --- Getters ---
  List<Message> get messages => List.unmodifiable(_messages);
  ChatMode get mode => _mode;
  Character? get currentCharacter => _currentCharacter;
  List<Character> get roomCharacters => List.unmodifiable(_roomCharacters);
  bool get isLoading => _isLoading;
  Set<String> get loadingCharacterIds => _loadingCharacterIds;

  /// 生成唯一 ID（原子操作）
  static String _genId() {
    final now = DateTime.now();
    return 'msg_${now.millisecondsSinceEpoch}_${now.microsecondsSinceEpoch}';
  }

  /// 是否有对话内容
  bool get hasMessages => _messages.isNotEmpty;

  /// 是否可发送（有角色且不在加载中）
  bool get canSend {
    if (_mode == ChatMode.single) return _currentCharacter != null && !_isLoading;
    return _roomCharacters.isNotEmpty && !_isLoading;
  }

  /// 构造历史消息（用于 API 请求）
  List<Message> _buildHistory() {
    return _messages
        .where((m) => !m.isLoading && (m.role == 'user' || m.role == 'assistant'))
        .toList();
  }

  /// 检查请求是否已因清空而过时
  bool _isStale(int clearCountAtStart) => _clearCount != clearCountAtStart;

  /// 根据消息 ID 更新内容（用于流式追加）
  void _updateMessageContent(String id, String newContent) {
    final index = _messages.indexWhere((m) => m.id == id);
    if (index == -1) return;
    _messages[index] = _messages[index].copyWith(content: newContent, isLoading: true);
  }

  /// 将消息标记为加载完成
  void _finishMessage(String id) {
    final index = _messages.indexWhere((m) => m.id == id);
    if (index == -1) return;
    _messages[index] = _messages[index].copyWith(isLoading: false);
  }

  // --- 初始化单人模式 ---
  void startSingleChat(Character character) {
    _mode = ChatMode.single;
    _currentCharacter = character;
    _roomCharacters = [];
    _messages.clear();
    _isLoading = false;
    _clearCount++;
    notifyListeners();
  }

  // --- 初始化聊天室模式 ---
  void startGroupChat(List<Character> characters) {
    _mode = ChatMode.group;
    _roomCharacters = characters;
    _currentCharacter = null;
    _messages.clear();
    _isLoading = false;
    _clearCount++;
    notifyListeners();
  }

  // --- 清空对话 ---
  void clearMessages() {
    _messages.clear();
    _isLoading = false;
    _loadingCharacterIds.clear();
    _clearCount++;
    notifyListeners();
  }

  // --- 发送消息 ---
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || !canSend) return;

    // 添加用户消息
    _messages.add(Message(
      id: _genId(),
      role: 'user',
      content: text.trim(),
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    if (_mode == ChatMode.single) {
      await _singleReply();
    } else {
      await _groupReplies();
    }
  }

  // --- 单人回复（流式） ---
  Future<void> _singleReply() async {
    if (_currentCharacter == null) return;

    final clearAtStart = _clearCount;
    final char = _currentCharacter!;

    // 先放一个空的占位消息
    final msgId = _genId();
    _messages.add(Message(
      id: msgId,
      role: 'assistant',
      characterId: char.id,
      characterName: char.name,
      characterEmoji: char.emoji,
      content: '',
      timestamp: DateTime.now(),
      isLoading: true,
    ));
    _isLoading = true;
    notifyListeners();

    try {
      final buffer = StringBuffer();
      // 节流：最频繁每 50ms 刷新一次 UI，防止抖动
      var lastNotify = DateTime.now();

      final fullText = await ApiService.chatStream(
        baseUrl: StorageService.baseUrl,
        apiKey: StorageService.apiKey ?? '',
        model: StorageService.model,
        systemPrompt: char.systemPrompt,
        history: _buildHistory(),
        userMessage: '',
        onDelta: (delta) {
          if (_isStale(clearAtStart)) return;
          buffer.write(delta);
          _updateMessageContent(msgId, buffer.toString());
          final now = DateTime.now();
          if (now.difference(lastNotify).inMilliseconds >= 50) {
            lastNotify = now;
            notifyListeners();
          }
        },
      );

      if (_isStale(clearAtStart)) return;

      // 如果 onDelta 从未被触发（如 SSE 格式不匹配），用返回的全量文本兜底
      if (buffer.isEmpty && fullText.isNotEmpty) {
        _updateMessageContent(msgId, fullText);
      }

      // 确保最终内容刷新
      _finishMessage(msgId);
    } catch (e) {
      if (_isStale(clearAtStart)) return;

      _updateMessageContent(msgId, '【出错了】${_sanitizeError(e)}');
      _finishMessage(msgId);
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- 多人依次回复（流式） ---
  Future<void> _groupReplies() async {
    final clearAtStart = _clearCount;
    _isLoading = true;

    for (final character in _roomCharacters) {
      if (_isStale(clearAtStart)) break;

      // 该角色的占位消息
      final msgId = _genId();
      _messages.add(Message(
        id: msgId,
        role: 'assistant',
        characterId: character.id,
        characterName: character.name,
        characterEmoji: character.emoji,
        content: '',
        timestamp: DateTime.now(),
        isLoading: true,
      ));
      _loadingCharacterIds.add(character.id);
      notifyListeners();

      try {
        final buffer = StringBuffer();
        var lastNotify = DateTime.now();

        final fullText = await ApiService.chatStream(
          baseUrl: StorageService.baseUrl,
          apiKey: StorageService.apiKey ?? '',
          model: StorageService.model,
          systemPrompt: character.systemPrompt,
          history: _buildHistory(),
          userMessage: '',
          onDelta: (delta) {
            if (_isStale(clearAtStart)) return;
            buffer.write(delta);
            _updateMessageContent(msgId, buffer.toString());
            final now = DateTime.now();
            if (now.difference(lastNotify).inMilliseconds >= 50) {
              lastNotify = now;
              notifyListeners();
            }
          },
        );

        if (_isStale(clearAtStart)) break;

        // 如果 onDelta 从未被触发，用返回的全量文本兜底
        if (buffer.isEmpty && fullText.isNotEmpty) {
          _updateMessageContent(msgId, fullText);
        }

        _finishMessage(msgId);
      } catch (e) {
        if (_isStale(clearAtStart)) break;

        _updateMessageContent(msgId, '【出错了】${_sanitizeError(e)}');
        _finishMessage(msgId);
      }

      _loadingCharacterIds.remove(character.id);
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 对用户友好地显示错误，避免泄露 API Key 等敏感信息
  String _sanitizeError(Object e) {
    final msg = e.toString();
    if (msg.contains('401') || msg.contains('Unauthorized')) {
      return 'API Key 无效，请在设置页检查';
    }
    if (msg.contains('timeout') || msg.contains('Timeout')) {
      return '请求超时，请检查网络或 API 地址';
    }
    if (msg.contains('Connection refused') ||
        msg.contains('No address') ||
        msg.contains('Failed host lookup')) {
      return '无法连接服务器，请检查 API 地址';
    }
    if (msg.contains('402') || msg.contains('Insufficient') || msg.contains('quota') || msg.contains('balance')) {
      return '账户余额不足，请充值';
    }
    // 一般错误只截取前 80 个字符
    return msg.length > 80 ? '${msg.substring(0, 80)}…' : msg;
  }
}
