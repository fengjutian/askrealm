import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/characters.dart';
import '../models/character.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../services/storage_service.dart';
import '../theme.dart';

/// 首页 — 剧场入口（Noir Cinema 风格）
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  bool get _isDesktop {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return true;
      default:
        return false;
    }
  }

  final List<_SidebarItem> _items = const [
    _SidebarItem(icon: Icons.person_outline, label: '单人对话'),
    _SidebarItem(icon: Icons.groups_outlined, label: '多人对话'),
    _SidebarItem(icon: Icons.settings_outlined, label: '设置'),
  ];

  void _onItemSelected(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/select', arguments: false);
        break;
      case 1:
        Navigator.pushNamed(context, '/select', arguments: true);
        break;
      case 2:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // ── 左侧边栏（剧场木纹暗条风格） ──
            if (_isDesktop)
              Container(
                width: 72,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF11100D) : const Color(0xFFEDE8E0),
                  border: Border(
                    right: BorderSide(
                      color: isDark ? noirDivider : const Color(0xFFDDD5C8),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // App 图标 — 金色微光场记板
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: spotlightGold.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: spotlightGold.withOpacity(0.18),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🎬', style: TextStyle(fontSize: 20)),
                      ),
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'v1.0',
                        style: TextStyle(fontSize: 10, color: warmGrey.withOpacity(0.6)),
                      ),
                    ),
                  ],
                ),
              ),

            // ── 右侧主内容区 ──
            Expanded(
              child: _buildWelcome(theme, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome(ThemeData theme, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // ── Logo — 聚光灯下场记板 ──
            Stack(
              alignment: Alignment.center,
              children: [
                // 金色光晕
                if (isDark)
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CustomPaint(painter: _SpotlightPainter()),
                  ),
                // 场记板容器
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: isDark ? noirCard : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark ? spotlightGold.withOpacity(0.5) : const Color(0xFFDDD5C8),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: spotlightGold.withOpacity(isDark ? 0.2 : 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🎬', style: TextStyle(fontSize: 48)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── 标题 — 金色大字 ──
            Text(
              '问戏',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: isDark ? spotlightGold : const Color(0xFF8B6914),
              ),
            ),
            const SizedBox(height: 8),

            // ── 副标题 — 电影字幕风 ──
            Text(
              '问于戏中，角色作答',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? warmGrey : const Color(0xFF8B8378),
                letterSpacing: 4,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 48),

            // ── 快速入口 — 电影票根风格 ──
            Wrap(
              spacing: 20,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _TicketCard(
                  icon: Icons.person_outline,
                  label: '单人对话',
                  subtitle: '选择一个角色，一对一畅聊',
                  isDark: isDark,
                  onTap: () => Navigator.pushNamed(context, '/select', arguments: false),
                ),
                _TicketCard(
                  icon: Icons.groups_outlined,
                  label: '多人聊天室',
                  subtitle: '选 2~4 个角色，同题共答',
                  isDark: isDark,
                  onTap: () => Navigator.pushNamed(context, '/select', arguments: true),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── API 状态 — 金色指示 ──
            Consumer<SettingsProvider>(
              builder: (context, settings, _) {
                final hasKey = settings.hasApiKey;
                return TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                  icon: Icon(
                    hasKey ? Icons.check_circle : Icons.warning_amber,
                    size: 16,
                    color: hasKey
                        ? spotlightGold.withOpacity(0.9)
                        : const Color(0xFFE8A840),
                  ),
                  label: Text(
                    hasKey ? 'API 已配置 — 可以开拍' : '请先配置 API',
                    style: TextStyle(
                      color: isDark ? warmGrey : const Color(0xFF8B8378),
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isDark ? noirDivider : const Color(0xFFDDD5C8)),
                    ),
                  ),
                );
              },
            ),

            // ── 已收藏的多人组合 ──
            _SavedCombosSection(isDark: isDark),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// ─── 聚光绘制器 ────────────────────────────────────────────────────
class _SpotlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          spotlightGold.withOpacity(0.12),
          spotlightGold.withOpacity(0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ─── 侧边栏按钮 — 金色选中指示条 ────────────────────────────────────
class _SidebarItem {
  final IconData icon;
  final String label;
  const _SidebarItem({required this.icon, required this.label});
}

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
                ? const Border(left: BorderSide(color: spotlightGold, width: 3))
                : null,
            color: isSelected ? spotlightGold.withOpacity(0.06) : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? spotlightGold : warmGrey.withOpacity(0.6),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? spotlightGold : warmGrey.withOpacity(0.6),
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

/// ─── 票根风格快速入口卡片 ──────────────────────────────────────────
class _TicketCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _TicketCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? noirCard : const Color(0xFFEDE6DA);
    final borderColor = isDark ? noirDivider : const Color(0xFFDDD5C8);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: const BorderSide(color: spotlightGold, width: 3),
            top: BorderSide(color: borderColor),
            right: BorderSide(color: borderColor),
            bottom: BorderSide(color: borderColor),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: spotlightGold),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? warmWhite : const Color(0xFF1A1A1A),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isDark ? warmGrey : const Color(0xFF8B8378),
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

/// ─── 已收藏组合区域 — 场记板标签 ─────────────────────────────────────
class _SavedCombosSection extends StatefulWidget {
  final bool isDark;
  const _SavedCombosSection({required this.isDark});

  @override
  State<_SavedCombosSection> createState() => _SavedCombosSectionState();
}

class _SavedCombosSectionState extends State<_SavedCombosSection> {
  List<List<String>> _combos = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCombos();
  }

  void _loadCombos() {
    _combos = StorageService.favoriteCombos;
  }

  @override
  Widget build(BuildContext context) {
    if (_combos.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark, size: 16, color: spotlightGold.withOpacity(0.7)),
            const SizedBox(width: 6),
            Text(
              '常用组合',
              style: TextStyle(
                color: warmGrey.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: _combos.map((combo) {
            final emojis = combo.map((id) {
              return AppCharacters.getById(id)?.emoji ?? '';
            }).join(' ');
            final names = combo.map((id) {
              return AppCharacters.getById(id)?.name ?? id;
            }).join('、');
            final chars = combo
                .map((id) => AppCharacters.getById(id))
                .whereType<Character>()
                .toList();

            return Tooltip(
              message: names,
              child: GestureDetector(
                onTap: () {
                  if (chars.length < 2) return;
                  context.read<ChatProvider>().startGroupChat(chars);
                  Navigator.pushReplacementNamed(context, '/chat/group');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.isDark ? noirCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: spotlightGold.withOpacity(0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emojis, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        '${combo.length}人',
                        style: TextStyle(
                          fontSize: 12,
                          color: warmGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 10, color: warmGrey.withOpacity(0.6)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
