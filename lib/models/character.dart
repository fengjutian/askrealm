import 'package:flutter/material.dart';

/// 影视角色数据模型
class Character {
  final String id;
  final String name;
  final String from; // 出自作品
  final String emoji; // 头像 Emoji
  final String description; // 性格描述
  final String systemPrompt; // 角色人设指令（给 AI 的 System Prompt）
  final String sampleLine; // 代表性台词
  final Color labelColor; // 聊天室中角色标签颜色

  const Character({
    required this.id,
    required this.name,
    required this.from,
    required this.emoji,
    required this.description,
    required this.systemPrompt,
    required this.sampleLine,
    this.labelColor = Colors.grey,
  });
}
