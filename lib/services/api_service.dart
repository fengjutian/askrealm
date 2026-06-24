import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/message.dart';

/// 大模型 API 调用服务
class ApiService {
  /// 发送单轮聊天请求，返回角色回复文本（非流式）
  static Future<String> chat({
    required String baseUrl,
    required String apiKey,
    required String model,
    required String systemPrompt,
    required List<Message> history,
    String userMessage = '',
  }) async {
    final url = Uri.parse(
        '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/v1/chat/completions');

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

  /// 发送流式聊天请求，通过 [onDelta] 回调逐 token 输出内容
  /// 返回完整拼接后的文本
  static Future<String> chatStream({
    required String baseUrl,
    required String apiKey,
    required String model,
    required String systemPrompt,
    required List<Message> history,
    String userMessage = '',
    required void Function(String delta) onDelta,
  }) async {
    final url = Uri.parse(
        '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/v1/chat/completions');

    // 构建消息列表
    final List<Map<String, String>> messages = [
      {'role': 'system', 'content': systemPrompt},
      ...history.map((m) => {
            'role': m.role == 'user' ? 'user' : 'assistant',
            'content': m.content,
          }),
      if (userMessage.isNotEmpty) {'role': 'user', 'content': userMessage},
    ];

    final body = jsonEncode({
      'model': model,
      'messages': messages,
      'temperature': 0.8,
      'max_tokens': 1000,
      'stream': true,
    });

    final request = http.Request('POST', url)
      ..headers.addAll({
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      })
      ..body = body;

    final client = http.Client();
    final completer = Completer<String>();
    final buffer = StringBuffer();

    try {
      final response = await client.send(request).timeout(
            const Duration(seconds: 60),
          );

      if (response.statusCode != 200) {
        // 先读完 body 以便构造错误信息
        final errorBody = await response.stream.bytesToString();
        throw HttpException(
          'API 请求失败 (${response.statusCode}): $errorBody',
        );
      }

      response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .timeout(const Duration(seconds: 30))
          .listen(
        (line) {
          // SSE 格式: data: {...}
          if (!line.startsWith('data:')) return;
          final data = line.substring(5).trim();

          // 结束标记
          if (data == '[DONE]') {
            if (!completer.isCompleted) {
              completer.complete(buffer.toString().trim());
            }
            return;
          }

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final choices = json['choices'] as List<dynamic>?;
            if (choices == null || choices.isEmpty) return;
            final delta = choices[0]['delta'] as Map<String, dynamic>?;
            final content = delta?['content'] as String?;
            if (content != null && content.isNotEmpty) {
              buffer.write(content);
              onDelta(content);
            }
          } catch (_) {
            // 忽略单个解析错误，继续处理后续行
          }
        },
        onError: (Object error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete(buffer.toString().trim());
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      client.close();
      rethrow;
    }

    // 确保 client 最终关闭
    return completer.future.whenComplete(client.close);
  }
}
