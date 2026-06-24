import 'package:flutter/material.dart';
import '../models/character.dart';

/// 角色选择卡片（支持单选 / 多选模式）
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
    final c = widget.character;
    final isSelected = widget.isSelected;

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
              color: isSelected
                  ? c.labelColor.withOpacity(0.15)
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? c.labelColor
                    : _isHovered
                        ? c.labelColor.withOpacity(0.3)
                        : theme.dividerColor,
                width: isSelected ? 2 : (_isHovered ? 1.5 : 1),
              ),
              boxShadow: isSelected || _isHovered
                  ? [
                      BoxShadow(
                        color: c.labelColor.withOpacity(isSelected ? 0.2 : 0.08),
                        blurRadius: 12,
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
                          // Emoji 头像
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c.labelColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                c.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // 名称 + 作品 + 标签
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
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? c.labelColor : null,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.brightness == Brightness.dark
                                            ? Colors.white.withOpacity(0.06)
                                            : Colors.black.withOpacity(0.04),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        c.from,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey[500],
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: c.labelColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: Text(
                                          tag,
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: c.labelColor,
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

                      // ── 代表台词（一行） ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: c.labelColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border(
                            left: BorderSide(
                              color: c.labelColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          '“${c.sampleLine}”',
                          style: TextStyle(
                            fontSize: 10,
                            color: c.labelColor.withOpacity(0.7),
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

                // 多选模式下的勾选标记
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
                        color: isSelected
                            ? c.labelColor
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? c.labelColor
                              : theme.brightness == Brightness.dark
                                  ? Colors.white38
                                  : Colors.black26,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
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
