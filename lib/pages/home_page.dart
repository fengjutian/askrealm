import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

/// 首页 — VS Code 风格左右布局
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<_SidebarItem> _items = const [
    _SidebarItem(icon: Icons.person_outline, label: '单人对话'),
    _SidebarItem(icon: Icons.groups_outlined, label: '多人对话'),
    _SidebarItem(icon: Icons.settings_outlined, label: '设置'),
  ];

  void _onItemSelected(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0: // 单人对话
        Navigator.pushNamed(context, '/select', arguments: false);
        break;
      case 1: // 多人对话
        Navigator.pushNamed(context, '/select', arguments: true);
        break;
      case 2: // 设置
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // ── 左侧边栏（Activity Bar）──
            Container(
              width: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border(
                  right: BorderSide(color: Colors.white.withOpacity(0.06)),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // App 图标
                  Text(
                    '🎬',
                    style: TextStyle(fontSize: 26),
                  ),
                  const SizedBox(height: 24),
                  // 导航按钮
                  ..._items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    final selected = _selectedIndex == i;
                    return _ActivityBarButton(
                      icon: item.icon,
                      label: item.label,
                      isSelected: selected,
                      onTap: () => _onItemSelected(i),
                    );
                  }),
                  const Spacer(),
                  // 底部版本号
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'v1.0',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 右侧主内容区 ──
            Expanded(
              child: _buildWelcome(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // 大 Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white12),
              ),
              child: const Center(
                child: Text('🎬', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 28),

            // 标题
            Text(
              '问戏',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '问于戏中，角色作答',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[500],
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 48),

            // 快速入口卡片
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _QuickEntryCard(
                  icon: Icons.person_outline,
                  label: '单人对话',
                  subtitle: '选择一个角色，一对一畅聊',
                  color: const Color(0xFF1E88E5),
                  onTap: () => Navigator.pushNamed(context, '/select', arguments: false),
                ),
                _QuickEntryCard(
                  icon: Icons.groups_outlined,
                  label: '多人聊天室',
                  subtitle: '选 2~4 个角色，同题共答',
                  color: const Color(0xFF64FFDA),
                  onTap: () => Navigator.pushNamed(context, '/select', arguments: true),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 当前 API 状态
            Consumer<SettingsProvider>(
              builder: (context, settings, _) {
                return TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                  icon: Icon(
                    settings.hasApiKey ? Icons.check_circle : Icons.warning_amber,
                    size: 16,
                    color: settings.hasApiKey ? Colors.green[400] : Colors.orange[400],
                  ),
                  label: Text(
                    settings.hasApiKey ? 'API 已配置' : '请先配置 API',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.white10),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// 侧边栏按钮数据
class _SidebarItem {
  final IconData icon;
  final String label;
  const _SidebarItem({required this.icon, required this.label});
}

/// 侧边栏活动按钮（VS Code Activity Bar 风格）
class _ActivityBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityBarButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      preferBelow: false,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: isSelected
                ? const Border(
                    left: BorderSide(color: Color(0xFF1E88E5), width: 3),
                  )
                : null,
            color: isSelected ? Colors.white.withOpacity(0.05) : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? const Color(0xFF1E88E5) : Colors.grey[500],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? const Color(0xFF1E88E5) : Colors.grey[500],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 右侧主区域快速入口卡片
class _QuickEntryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickEntryCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
