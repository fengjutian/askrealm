import 'package:flutter/material.dart';
import '../models/character.dart';
import '../theme.dart';

/// 角色选择卡片 — 电影海报风格（Noir Cinema）
class CharacterCard extends StatefulWidget {
  final Character character;
  final bool isSelected;
  final bool isMultiSelect;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const CharacterCard({
    super.key,
    required this.character,
    this.isSelected = false,
    this.isMultiSelect = false,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final c = widget.character;
    final isSelected = widget.isSelected;
    final cardBg = isDark ? noirCard : Colors.white;
    final borderBase = isDark ? noirDivider : const Color(0xFFDDD5C8);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? c.labelColor.withOpacity(0.1) : cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? spotlightGold
                    : _isHovered
                        ? c.labelColor.withOpacity(0.35)
                        : borderBase,
                width: isSelected ? 1.5 : (_isHovered ? 1.3 : 1),
              ),
              boxShadow: isSelected || _isHovered
                  ? [
                      BoxShadow(
                        color: (isSelected ? spotlightGold : c.labelColor)
                            .withOpacity(isSelected ? 0.18 : 0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Emoji + 基本信息 ──
                      Row(
                        children: [
                          // Emoji 头像 — 金色微光底
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c.labelColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: spotlightGold.withOpacity(0.15),
                                    blurRadius: 8,
                                  ),
                              ],
                            ),
                            child: Center(
                              child: Text(c.emoji, style: const TextStyle(fontSize: 24)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        c.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? (isDark ? spotlightGold : const Color(0xFF8B6914))
                                              : (isDark ? warmWhite : const Color(0xFF1A1A1A)),
                                          letterSpacing: 0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? warmWhite.withOpacity(0.05)
                                            : Colors.black.withOpacity(0.04),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        c.from,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: warmGrey.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                // 标签
                                Row(
                                  children: c.tags.take(2).map((tag) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: c.labelColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: Text(
                                          tag,
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: c.labelColor.withOpacity(0.8),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // ── 代表台词 — 电影字幕感 ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.labelColor.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(6),
                          border: Border(
                            left: BorderSide(
                              color: c.labelColor.withOpacity(0.25),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          '"${c.sampleLine}"',
                          style: TextStyle(
                            fontSize: 10,
                            color: c.labelColor.withOpacity(0.6),
                            height: 1.3,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // 多选模式下的勾选标记 — 金色
                if (widget.isMultiSelect)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? spotlightGold : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? spotlightGold
                              : isDark
                                  ? warmWhite.withOpacity(0.2)
                                  : Colors.black26,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 14, color: Color(0xFF0A0A0A))
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
