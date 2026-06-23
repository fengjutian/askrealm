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

  // --- 初始化单人模式 ---
  void startSingleChat(Character character) {
    _mode = ChatMode.single;
    _currentCharacter = character;
    _roomCharacters = [];
    _messages.clear();
    _clearCount++;
    notifyListeners();
  }

  // --- 初始化聊天室模式 ---
  void startGroupChat(List<Character> characters) {
    _mode = ChatMode.group;
    _roomCharacters = characters;
    _currentCharacter = null;
    _messages.clear();
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

  // --- 单人回复 ---
  Future<void> _singleReply() async {
    if (_currentCharacter == null) return;

    final clearAtStart = _clearCount;
    _isLoading = true;
    notifyListeners();

    try {
      final reply = await ApiService.chat(
        baseUrl: StorageService.baseUrl,
        apiKey: StorageService.apiKey ?? '',
        model: StorageService.model,
        systemPrompt: _currentCharacter!.systemPrompt,
        history: _buildHistory(),
        userMessage: '',
      );

      if (_isStale(clearAtStart)) return;

      _messages.add(Message(
        id: _genId(),
        role: 'assistant',
        characterId: _currentCharacter!.id,
        characterName: _currentCharacter!.name,
        characterEmoji: _currentCharacter!.emoji,
        content: reply,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      if (_isStale(clearAtStart)) return;

      _messages.add(Message(
        id: _genId(),
        role: 'assistant',
        characterId: _currentCharacter!.id,
        characterName: _currentCharacter!.name,
        characterEmoji: _currentCharacter!.emoji,
        content: '【出错了】${_sanitizeError(e)}',
        timestamp: DateTime.now(),
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- 多人依次回复 ---
  Future<void> _groupReplies() async {
    final clearAtStart = _clearCount;
    _isLoading = true;

    for (final character in _roomCharacters) {
      if (_isStale(clearAtStart)) break;

      _loadingCharacterIds.add(character.id);
      notifyListeners();

      try {
        final reply = await ApiService.chat(
          baseUrl: StorageService.baseUrl,
          apiKey: StorageService.apiKey ?? '',
          model: StorageService.model,
          systemPrompt: character.systemPrompt,
          history: _buildHistory(),
          userMessage: '',
        );

        if (_isStale(clearAtStart)) break;

        _messages.add(Message(
          id: _genId(),
          role: 'assistant',
          characterId: character.id,
          characterName: character.name,
          characterEmoji: character.emoji,
          content: reply,
          timestamp: DateTime.now(),
        ));
      } catch (e) {
        if (_isStale(clearAtStart)) break;

        _messages.add(Message(
          id: _genId(),
          role: 'assistant',
          characterId: character.id,
          characterName: character.name,
          characterEmoji: character.emoji,
          content: '【出错了】${_sanitizeError(e)}',
          timestamp: DateTime.now(),
        ));
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
