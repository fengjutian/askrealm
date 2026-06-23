/// 对话模式
enum ChatMode { single, group }

/// 消息数据模型
class Message {
  final String id;
  final String role; // 'user' | 'assistant'
  final String? characterId; // 角色 id（assistant 消息需要）
  final String? characterName; // 角色显示名
  final String? characterEmoji; // 角色 Emoji
  final String content;
  final DateTime timestamp;
  final bool isLoading; // 是否正在加载中

  const Message({
    required this.id,
    required this.role,
    this.characterId,
    this.characterName,
    this.characterEmoji,
    required this.content,
    required this.timestamp,
    this.isLoading = false,
  });

  /// 创建一个加载中的占位消息
  factory Message.loading({
    required String characterId,
    required String characterName,
    required String characterEmoji,
  }) {
    return Message(
      id: 'loading_${characterId}_${DateTime.now().millisecondsSinceEpoch}',
      role: 'assistant',
      characterId: characterId,
      characterName: characterName,
      characterEmoji: characterEmoji,
      content: '',
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  /// 复制并更新内容
  Message copyWith({
    String? id,
    String? role,
    String? characterId,
    String? characterName,
    String? characterEmoji,
    String? content,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return Message(
      id: id ?? this.id,
      role: role ?? this.role,
      characterId: characterId ?? this.characterId,
      characterName: characterName ?? this.characterName,
      characterEmoji: characterEmoji ?? this.characterEmoji,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
