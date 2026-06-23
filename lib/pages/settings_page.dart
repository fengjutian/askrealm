import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

/// 设置页 — API Key / Base URL / Model 配置
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final baseUrlController =
            TextEditingController(text: settings.baseUrl);
        final apiKeyController =
            TextEditingController(text: settings.apiKey);
        final modelController =
            TextEditingController(text: settings.model);

        return Scaffold(
          appBar: AppBar(
            title: const Text('API 配置'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 状态提示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: settings.hasApiKey
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: settings.hasApiKey
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      settings.hasApiKey ? Icons.check_circle : Icons.warning,
                      color: settings.hasApiKey ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        settings.hasApiKey
                            ? 'API 已配置，可以开始对话'
                            : '请先填写 API Key 才能使用',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: settings.hasApiKey
                              ? Colors.green[300]
                              : Colors.orange[300],
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
                controller: baseUrlController,
                hintText: '如 https://api.deepseek.com',
                onChanged: settings.setBaseUrl,
              ),
              const SizedBox(height: 16),

              // API Key
              _SectionLabel(label: 'API Key'),
              const SizedBox(height: 8),
              _ConfigField(
                controller: apiKeyController,
                hintText: 'sk-xxxxxxxxxxxxxxxx',
                obscureText: true,
                onChanged: settings.setApiKey,
              ),
              const SizedBox(height: 16),

              // Model
              _SectionLabel(label: '模型名称'),
              const SizedBox(height: 8),
              _ConfigField(
                controller: modelController,
                hintText: '如 deepseek-chat / gpt-4o-mini',
                onChanged: settings.setModel,
              ),
              const SizedBox(height: 32),

              // 常见模型推荐
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 常见配置参考',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ReferenceRow(
                      name: 'DeepSeek',
                      baseUrl: 'https://api.deepseek.com',
                      model: 'deepseek-chat',
                    ),
                    const SizedBox(height: 8),
                    _ReferenceRow(
                      name: 'OpenAI',
                      baseUrl: 'https://api.openai.com',
                      model: 'gpt-4o-mini',
                    ),
                    const SizedBox(height: 8),
                    _ReferenceRow(
                      name: 'Moonshot（月之暗面）',
                      baseUrl: 'https://api.moonshot.cn',
                      model: 'moonshot-v1-8k',
                    ),
                    const SizedBox(height: 8),
                    _ReferenceRow(
                      name: '智谱 GLM',
                      baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
                      model: 'glm-4-flash',
                    ),
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
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.grey[400],
            fontWeight: FontWeight.w600,
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
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
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            name,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[400],
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
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
              Text(
                model,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
