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

  // --- Getters ---
  List<Message> get messages => List.unmodifiable(_messages);
  ChatMode get mode => _mode;
  Character? get currentCharacter => _currentCharacter;
  List<Character> get roomCharacters => List.unmodifiable(_roomCharacters);
  bool get isLoading => _isLoading;
  Set<String> get loadingCharacterIds => _loadingCharacterIds;

  /// 生成唯一 ID
  static String _genId() =>
      'msg_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';

  /// 是否有对话内容
  bool get hasMessages => _messages.isNotEmpty;

  /// 是否可发送（有角色且不在加载中）
  bool get canSend {
    if (_mode == ChatMode.single) return _currentCharacter != null && !_isLoading;
    return _roomCharacters.isNotEmpty && !_isLoading;
  }

  // --- 初始化单人模式 ---
  void startSingleChat(Character character) {
    _mode = ChatMode.single;
    _currentCharacter = character;
    _roomCharacters = [];
    _messages.clear();
    notifyListeners();
  }

  // --- 初始化聊天室模式 ---
  void startGroupChat(List<Character> characters) {
    _mode = ChatMode.group;
    _roomCharacters = characters;
    _currentCharacter = null;
    _messages.clear();
    notifyListeners();
  }

  // --- 清空对话 ---
  void clearMessages() {
    _messages.clear();
    _isLoading = false;
    _loadingCharacterIds.clear();
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
      await _singleReply(text);
    } else {
      await _groupReplies(text);
    }
  }

  // --- 单人回复 ---
  Future<void> _singleReply(String text) async {
    if (_currentCharacter == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final reply = await ApiService.chat(
        baseUrl: StorageService.baseUrl,
        apiKey: StorageService.apiKey ?? '',
        model: StorageService.model,
        systemPrompt: _currentCharacter!.systemPrompt,
        history: _messages.where((m) => m.role == 'user' || m.role == 'assistant').toList(),
        userMessage: '',
      );

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
      _messages.add(Message(
        id: _genId(),
        role: 'assistant',
        characterId: _currentCharacter!.id,
        characterName: _currentCharacter!.name,
        characterEmoji: _currentCharacter!.emoji,
        content: '【出错了】$e',
        timestamp: DateTime.now(),
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- 多人依次回复 ---
  Future<void> _groupReplies(String text) async {
    _isLoading = true;

    // 依次为每个角色获取回复
    for (final character in _roomCharacters) {
      _loadingCharacterIds.add(character.id);
      notifyListeners();

      try {
        // 构建历史消息（只包含 content 角色信息，不包含 loading 消息）
        final history = _messages
            .where((m) => !m.isLoading && (m.role == 'user' || m.role == 'assistant'))
            .toList();

        final reply = await ApiService.chat(
          baseUrl: StorageService.baseUrl,
          apiKey: StorageService.apiKey ?? '',
          model: StorageService.model,
          systemPrompt: character.systemPrompt,
          history: history,
          userMessage: text,
        );

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
        _messages.add(Message(
          id: _genId(),
          role: 'assistant',
          characterId: character.id,
          characterName: character.name,
          characterEmoji: character.emoji,
          content: '【出错了】$e',
          timestamp: DateTime.now(),
        ));
      }

      _loadingCharacterIds.remove(character.id);
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }
}
