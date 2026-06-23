import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/characters.dart';
import '../models/character.dart';
import '../providers/chat_provider.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isGroupMode = ModalRoute.of(context)?.settings.arguments is bool
        ? (ModalRoute.of(context)!.settings.arguments as bool)
        : false;
  }

  void _onCharacterTap(Character character) {
    if (_isGroupMode) {
      // 多人模式：多选
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
            ),
          );
        }
      });
    } else {
      // 单人模式：点击即进入
      context.read<ChatProvider>().startSingleChat(character);
      Navigator.pushReplacementNamed(context, '/chat/single');
    }
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
      ),
      body: Column(
        children: [
          // 提示文字
          if (_isGroupMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                '请选择 2~4 个角色加入聊天室\n（已选 ${_selectedIds.length} 个）',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // 角色网格
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
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
                );
              },
            ),
          ),

          // 聊天室模式：开始按钮
          if (_isGroupMode)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        _selectedIds.length >= 2 ? _startGroupChat : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      '开始聊天',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
