import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/characters.dart';
import '../models/character.dart';
import '../providers/chat_provider.dart';
import '../services/storage_service.dart';
import '../widgets/character_card.dart';

/// 角色选择页
/// arguments: bool — true=多人模式（多选），false=单人模式（单选）
class CharacterSelectPage extends StatefulWidget {
  const CharacterSelectPage({super.key});

  @override
  State<CharacterSelectPage> createState() => _CharacterSelectPageState();
}

class _CharacterSelectPageState extends State<CharacterSelectPage> {
  late bool _isGroupMode;
  final Set<String> _selectedIds = {};
  List<List<String>> _savedCombos = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isGroupMode = ModalRoute.of(context)?.settings.arguments is bool
        ? (ModalRoute.of(context)!.settings.arguments as bool)
        : false;
    _loadSavedCombos();
  }

  void _loadSavedCombos() {
    if (_isGroupMode) {
      _savedCombos = StorageService.favoriteCombos;
    }
  }

  void _onCharacterTap(Character character) {
    if (_isGroupMode) {
      setState(() {
        if (_selectedIds.contains(character.id)) {
          _selectedIds.remove(character.id);
        } else if (_selectedIds.length < 4) {
          _selectedIds.add(character.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('最多选 4 个角色'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
            ),
          );
        }
      });
    } else {
      context.read<ChatProvider>().startSingleChat(character);
      Navigator.pushReplacementNamed(context, '/chat/single');
    }
  }

  /// 长按显示角色详情
  void _showCharacterDetail(Character character) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji
              Text(character.emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 12),
              // 名称
              Text(
                character.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // 作品
              Text(
                character.from,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 12),
              // 标签
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: character.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: character.labelColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: character.labelColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // 描述
              Text(
                character.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // 代表台词
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: character.labelColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(
                      color: character.labelColor.withOpacity(0.4),
                      width: 4,
                    ),
                  ),
                ),
                child: Text(
                  '“${character.sampleLine}”',
                  style: TextStyle(
                    fontSize: 15,
                    color: character.labelColor.withOpacity(0.85),
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
          if (!_isGroupMode)
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _onCharacterTap(character);
              },
              icon: const Icon(Icons.chat_outlined, size: 18),
              label: const Text('开始对话'),
            ),
        ],
      ),
    );
  }

  /// 收藏当前组合
  Future<void> _saveCurrentCombo() async {
    final ids = _selectedIds.toList();
    if (ids.length < 2) return;

    final names = ids.map((id) {
      return AppCharacters.getById(id)?.name ?? id;
    }).join('、');

    final added = await StorageService.addFavoriteCombo(ids);
    if (!mounted) return;

    if (added) {
      _loadSavedCombos();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已收藏组合「$names」'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('该组合已收藏'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  /// 从收藏组合加载
  void _loadCombo(List<String> charIds) {
    setState(() {
      _selectedIds.clear();
      _selectedIds.addAll(charIds);
    });
  }

  void _startGroupChat() {
    if (_selectedIds.isEmpty) return;

    final selectedChars = AppCharacters.all
        .where((c) => _selectedIds.contains(c.id))
        .toList();

    context.read<ChatProvider>().startGroupChat(selectedChars);
    Navigator.pushReplacementNamed(context, '/chat/group');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isGroupMode ? '选择聊天室成员' : '选择角色'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isGroupMode && _savedCombos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.bookmark_outline),
              tooltip: '已收藏的组合',
              onPressed: () => _showSavedCombosSheet(),
            ),
        ],
      ),
      body: Column(
        children: [
          // 提示文字
          if (_isGroupMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                '请选择 2~4 个角色加入聊天室\n（已选 ${_selectedIds.length} 个）',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                '点击角色开始对话 · 长按查看详情',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // 角色网格
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.15,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: AppCharacters.all.length,
              itemBuilder: (context, index) {
                final character = AppCharacters.all[index];
                return CharacterCard(
                  character: character,
                  isSelected: _selectedIds.contains(character.id),
                  isMultiSelect: _isGroupMode,
                  onTap: () => _onCharacterTap(character),
                  onLongPress: () => _showCharacterDetail(character),
                );
              },
            ),
          ),

          // 多人模式底部操作栏
          if (_isGroupMode)
            SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(color: theme.dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    // 收藏按钮
                    if (_selectedIds.length >= 2)
                      IconButton(
                        icon: const Icon(Icons.bookmark_add_outlined),
                        tooltip: '收藏此组合',
                        onPressed: _saveCurrentCombo,
                      ),
                    const Spacer(),
                    // 开始聊天按钮
                    SizedBox(
                      width: 200,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _selectedIds.length >= 2
                            ? _startGroupChat
                            : null,
                        icon: const Icon(Icons.chat_outlined, size: 18),
                        label: Text(
                          _selectedIds.isEmpty
                              ? '选择角色'
                              : '开始聊天（${_selectedIds.length}人）',
                          style: const TextStyle(fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 底部弹出已收藏的组合列表
  void _showSavedCombosSheet() {
    _loadSavedCombos();
    if (_savedCombos.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bookmark, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '已收藏的组合',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._savedCombos.asMap().entries.map((entry) {
                final i = entry.key;
                final combo = entry.value;
                final names = combo.map((id) {
                  return AppCharacters.getById(id)?.name ?? id;
                }).toList();
                final emojis = combo.map((id) {
                  return AppCharacters.getById(id)?.emoji ?? '';
                }).join(' ');

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Text(emojis, style: const TextStyle(fontSize: 24)),
                    title: Text(
                      names.join('、'),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text('${combo.length} 个角色'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          tooltip: '删除收藏',
                          onPressed: () async {
                            await StorageService.removeFavoriteCombo(combo);
                            _loadSavedCombos();
                            if (ctx.mounted) {
                              // 刷新底部弹窗
                              Navigator.pop(ctx);
                              if (_savedCombos.isNotEmpty) {
                                _showSavedCombosSheet();
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            _loadCombo(combo);
                            Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('选用'),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
