import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/message.dart';

/// 大模型 API 调用服务
class ApiService {
  /// 发送单轮聊天请求，返回角色回复文本
  static Future<String> chat({
    required String baseUrl,
    required String apiKey,
    required String model,
    required String systemPrompt,
    required List<Message> history,
    String userMessage = '',
  }) async {
    final url = Uri.parse('${baseUrl.trimRight('/')}/v1/chat/completions');

    // 构建消息列表
    final List<Map<String, String>> messages = [
      {'role': 'system', 'content': systemPrompt},
      // 将历史消息加入
      ...history.map((m) => {
            'role': m.role == 'user' ? 'user' : 'assistant',
            'content': m.content,
          }),
      // 当前用户消息
      if (userMessage.isNotEmpty) {'role': 'user', 'content': userMessage},
    ];

    final response = await http
        .post(
          url,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'messages': messages,
            'temperature': 0.8,
            'max_tokens': 1000,
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'] ?? '';
      return content.toString().trim();
    } else {
      throw HttpException(
        'API 请求失败 (${response.statusCode}): ${response.body}',
      );
    }
  }
}
