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
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Emoji 头像 + 作品名 ──
                      Row(
                        children: [
                          Text(c.emoji, style: const TextStyle(fontSize: 36)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.06)
                                  : Colors.black.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              c.from,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ── 角色名 ──
                      Text(
                        c.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? c.labelColor : null,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // ── 标签行 ──
                      SizedBox(
                        height: 22,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: c.tags.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 4),
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: c.labelColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                c.tags[index],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: c.labelColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 6),

                      // ── 性格描述 ──
                      Text(
                        c.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[400],
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),

                      // ── 代表台词（突出展示） ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: c.labelColor.withOpacity(
                            _isHovered ? 0.12 : 0.06,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            left: BorderSide(
                              color: c.labelColor.withOpacity(0.4),
                              width: 3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '“${c.sampleLine}”',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: c.labelColor.withOpacity(0.8),
                                  height: 1.3,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 多选模式下的勾选标记
                if (widget.isMultiSelect)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
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
                              size: 16,
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
