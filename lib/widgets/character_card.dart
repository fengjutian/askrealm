import 'package:flutter/material.dart';
import '../models/character.dart';

/// 角色选择卡片（支持单选 / 多选模式）
class CharacterCard extends StatelessWidget {
  final Character character;
  final bool isSelected;
  final bool isMultiSelect;
  final VoidCallback onTap;

  const CharacterCard({
    super.key,
    required this.character,
    this.isSelected = false,
    this.isMultiSelect = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? character.labelColor.withOpacity(0.2)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? character.labelColor : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji 头像
                  Text(
                    character.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 12),
                  // 角色名
                  Text(
                    character.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? character.labelColor : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 出自作品
                  Text(
                    character.from,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 性格描述
                  Text(
                    character.description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[400],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 多选模式下的勾选标记
            if (isMultiSelect)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? character.labelColor : Colors.white24,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
