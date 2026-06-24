import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme.dart';

/// 设置页 — 后台控制室风格（Noir Cinema）
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _baseUrlController;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;
  bool _isTesting = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _baseUrlController = TextEditingController(text: settings.baseUrl);
    _apiKeyController = TextEditingController(text: settings.apiKey);
    _modelController = TextEditingController(text: settings.model);
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final baseUrl = _baseUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    final model = _modelController.text.trim();

    try {
      final url = Uri.parse('${baseUrl.replaceAll(RegExp(r'/+$'), '')}/v1/chat/completions');
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {'role': 'user', 'content': '你好，回复一个字就行。'}
              ],
              'max_tokens': 10,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        setState(() => _testResult = '✅ 连接成功！API Key 有效');
      } else {
        setState(() => _testResult = '❌ 请求失败 (${response.statusCode})');
      }
    } catch (e) {
      setState(() => _testResult = '❌ 连接失败：$e');
    }

    setState(() => _isTesting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('API 配置'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: warmGrey),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── 状态提示卡 ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: settings.hasApiKey
                      ? spotlightGold.withOpacity(0.08)
                      : const Color(0xFFE8A840).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: settings.hasApiKey
                        ? spotlightGold.withOpacity(0.25)
                        : const Color(0xFFE8A840).withOpacity(0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      settings.hasApiKey ? Icons.check_circle : Icons.warning,
                      color: settings.hasApiKey ? spotlightGold : const Color(0xFFE8A840),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        settings.hasApiKey ? 'API 已配置 — 可以开拍' : '请先填写 API Key 才能使用',
                        style: TextStyle(
                          fontSize: 14,
                          color: settings.hasApiKey
                              ? spotlightGold.withOpacity(0.9)
                              : const Color(0xFFE8A840).withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // API Base URL
              _SectionLabel(label: 'API 接口地址'),
              const SizedBox(height: 8),
              _ConfigField(
                controller: _baseUrlController,
                hintText: '如 https://api.deepseek.com',
                onChanged: settings.setBaseUrl,
              ),
              const SizedBox(height: 16),

              // API Key
              _SectionLabel(label: 'API Key'),
              const SizedBox(height: 8),
              _ConfigField(
                controller: _apiKeyController,
                hintText: 'sk-xxxxxxxxxxxxxxxx',
                obscureText: true,
                onChanged: settings.setApiKey,
              ),
              const SizedBox(height: 16),

              // Model
              _SectionLabel(label: '模型名称'),
              const SizedBox(height: 8),
              _ConfigField(
                controller: _modelController,
                hintText: '如 deepseek-v4-flash / gpt-4o-mini',
                onChanged: settings.setModel,
              ),
              const SizedBox(height: 24),

              // ── 测试连接按钮 — 金色 ──
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isTesting ? null : _testConnection,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.wifi_find, color: Color(0xFF0A0A0A)),
                  label: Text(
                    _isTesting ? '测试中…' : '测试连接',
                    style: const TextStyle(color: Color(0xFF0A0A0A)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: spotlightGold,
                    disabledBackgroundColor: noirDivider,
                    disabledForegroundColor: warmGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),

              // 测试结果
              if (_testResult != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _testResult!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: _testResult!.startsWith('✅')
                          ? spotlightGold.withOpacity(0.9)
                          : curtainRed.withOpacity(0.8),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // ── 外观设置 ──
              _SectionLabel(label: '外观'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? noirCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? noirDivider : const Color(0xFFDDD5C8)),
                ),
                child: Row(
                  children: [
                    Icon(
                      settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: spotlightGold,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '深色模式',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? warmWhite : const Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            settings.isDarkMode ? '当前为深色主题' : '当前为明亮主题',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? warmWhite54 : const Color(0xFF8B8378),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: settings.isDarkMode,
                      onChanged: (_) => settings.toggleTheme(),
                      activeColor: spotlightGold,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── 常见配置参考 ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? noirCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: spotlightGold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '常见配置参考',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? warmWhite : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ReferenceRow(name: 'DeepSeek', baseUrl: 'https://api.deepseek.com', model: 'deepseek-v4-flash'),
                    const SizedBox(height: 8),
                    _ReferenceRow(name: 'OpenAI', baseUrl: 'https://api.openai.com', model: 'gpt-4o-mini'),
                    const SizedBox(height: 8),
                    _ReferenceRow(name: 'Moonshot（月之暗面）', baseUrl: 'https://api.moonshot.cn', model: 'moonshot-v1-8k'),
                    const SizedBox(height: 8),
                    _ReferenceRow(name: '智谱 GLM', baseUrl: 'https://open.bigmodel.cn/api/paas/v4', model: 'glm-4-flash'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        color: isDark ? warmGrey : const Color(0xFF8B8378),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _ConfigField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final ValueChanged<String> onChanged;

  const _ConfigField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? noirCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? noirDivider : const Color(0xFFDDD5C8)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          color: isDark ? warmWhite : const Color(0xFF1A1A1A),
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: warmGrey.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _ReferenceRow extends StatelessWidget {
  final String name;
  final String baseUrl;
  final String model;

  const _ReferenceRow({
    required this.name,
    required this.baseUrl,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                baseUrl,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? warmWhite54 : const Color(0xFF8B8378),
                ),
              ),
              Text(
                model,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? warmWhite54 : const Color(0xFF8B8378),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
