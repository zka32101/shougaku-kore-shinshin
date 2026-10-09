import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_providers.dart';
import '../../models/composition.dart';
import '../../theme/app_theme.dart';
import 'package:shougaku_kore_doutoku/widgets/furigana_text.dart';

class ThemeComposeScreen extends ConsumerStatefulWidget {
  const ThemeComposeScreen({super.key});

  @override
  ConsumerState<ThemeComposeScreen> createState() => _ThemeComposeScreenState();
}

class _ThemeComposeScreenState extends ConsumerState<ThemeComposeScreen> {
  static const _themes = [
    {'emoji': '🌸', 'name': '春', 'hint': '桜・温かさ・始まり', 'color': Color(0xFFE91E8C)},
    {'emoji': '🌊', 'name': '夏', 'hint': '海・元気・情熱', 'color': Color(0xFF2196F3)},
    {'emoji': '🍁', 'name': '秋', 'hint': '紅葉・寂しさ・穏やか', 'color': Color(0xFFE67E22)},
    {'emoji': '❄️', 'name': '冬', 'hint': '雪・静けさ・キリリ', 'color': Color(0xFF9E9E9E)},
    {'emoji': '😊', 'name': '喜び', 'hint': 'うれしい・跳ねる・明るい', 'color': Color(0xFFF1C40F)},
    {'emoji': '😢', 'name': '悲しみ', 'hint': '涙・ゆっくり・やさしく', 'color': Color(0xFF607D8B)},
    {'emoji': '🔥', 'name': 'ワクワク', 'hint': '速い・強い・冒険', 'color': Color(0xFFE74C3C)},
    {'emoji': '🌙', 'name': '夜', 'hint': 'しずか・神秘・星', 'color': Color(0xFF311B92)},
    {'emoji': '🦁', 'name': '勇気', 'hint': '力強い・前へ・諦めない', 'color': Color(0xFF795548)},
    {'emoji': '🕊️', 'name': '平和', 'hint': '穏やか・優しい・まとまり', 'color': Color(0xFF4CAF50)},
    {'emoji': '🎮', 'name': '冒険', 'hint': '軽快・楽しい・リズミカル', 'color': Color(0xFF9C27B0)},
    {'emoji': '🏠', 'name': '家族', 'hint': '温かい・一緒・ゆっくり', 'color': Color(0xFFFF6B35)},
  ];

  String? _selectedTheme;
  final List<String> _melody = [];
  final _descCtrl = TextEditingController();
  bool _saved = false;

  static const _noteColors = {
    'ド': Color(0xFFE74C3C),
    'レ': Color(0xFFE67E22),
    'ミ': Color(0xFFF1C40F),
    'ファ': Color(0xFF27AE60),
    'ソ': Color(0xFF2980B9),
    'ラ': Color(0xFF8E44AD),
    'シ': Color(0xFFE91E8C),
  };

  void _addNote(String note) {
    if (_melody.length < 16) setState(() => _melody.add(note));
  }

  void _removeLastNote() {
    if (_melody.isNotEmpty) setState(() => _melody.removeLast());
  }

  Future<void> _save() async {
    if (_selectedTheme == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: FuriganaText('テーマを選んでね！')),
      );
      return;
    }
    if (_melody.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: FuriganaText('3音以上入力してね！')),
      );
      return;
    }

    final theme = _themes.firstWhere((t) => t['name'] == _selectedTheme);
    final composition = Composition(
      id: const Uuid().v4(),
      stage: CompositionStage.stage1,
      title: '${theme['emoji']}$_selectedThemeの曲',
      theme: _selectedTheme!,
      instrument: 'theme_piano',
      pattern: _selectedTheme!,
      melody: _melody.map((n) => NoteEntry(note: n, duration: 1.0)).toList(),
      timesignature: '4/4',
      tempo: 80,
      chords: [],
      hasDrums: false,
      hasVocal: false,
      badges: ['music_theme_compose'],
      createdAt: DateTime.now(),
    );
    await ref.read(compositionProvider.notifier).add(composition);
    await ref.read(badgeProvider.notifier).award(
      'music_theme_compose_$_selectedTheme',
      '${theme['emoji']}$_selectedThemeの作曲家',
      'music', '🎼',
      '$_selectedThemeのテーマで曲を作った',
    );
    setState(() => _saved = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: FuriganaText('「$_selectedTheme」の曲を保存したよ！🎉'),
          backgroundColor: theme['color'] as Color,
        ),
      );
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedData = _selectedTheme != null
        ? _themes.firstWhere((t) => t['name'] == _selectedTheme)
        : null;
    final themeColor = selectedData?['color'] as Color? ?? kMusicColor;

    return Scaffold(
      appBar: AppBar(
        title: const FuriganaText('🎼 テーマ作曲チャレンジ'),
        backgroundColor: kMusicColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Step 1: テーマ選択
          _StepCard(
            step: 1,
            title: 'テーマを選ぼう',
            color: kMusicColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FuriganaText(
                  'このテーマのイメージを音で表現してみよう！\nどんなリズム？速い？ゆっくり？明るい？',
                  style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _themes.map((t) {
                    final isSelected = _selectedTheme == t['name'];
                    final color = t['color'] as Color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTheme = t['name'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color, width: isSelected ? 2 : 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(t['emoji'] as String, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 4),
                            FuriganaText(
                              t['name'] as String,
                              style: TextStyle(
                                color: isSelected ? Colors.white : color,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (selectedData != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(selectedData['emoji'] as String, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FuriganaText(
                              selectedData['name'] as String,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: themeColor),
                            ),
                            FuriganaText(
                              selectedData['hint'] as String,
                              style: TextStyle(fontSize: 12, color: themeColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Step 2: メロディ入力
          _StepCard(
            step: 2,
            title: 'メロディを作ろう（最大16音）',
            color: const Color(0xFF2196F3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FuriganaText(
                  '下の鍵盤をタップして音を入力しよう！\nテーマのイメージに合うメロディを考えてね',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                ),
                const SizedBox(height: 12),

                // メロディ表示
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: _melody.isEmpty
                      ? const FuriganaText('ここに音が並ぶよ…', style: TextStyle(color: Colors.grey, fontSize: 13))
                      : Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: _melody.map((n) {
                            final color = _noteColors[n] ?? kMusicColor;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(n, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            );
                          }).toList(),
                        ),
                  ),
                ),

                const SizedBox(height: 12),

                // 鍵盤ボタン
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _noteColors.entries.map((e) {
                    return GestureDetector(
                      onTap: () => _addNote(e.key),
                      child: Container(
                        width: 52,
                        height: 64,
                        decoration: BoxDecoration(
                          color: _melody.length >= 16 ? Colors.grey[300] : e.value,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: e.value.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 3))],
                        ),
                        child: Center(
                          child: Text(
                            e.key,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 8),
                Row(
                  children: [
                    FuriganaText('${_melody.length}/16音', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _removeLastNote,
                      icon: const Icon(Icons.backspace_outlined, size: 16),
                      label: const FuriganaText('1音消す'),
                      style: TextButton.styleFrom(foregroundColor: Colors.orange),
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() => _melody.clear()),
                      icon: const Icon(Icons.clear, size: 16),
                      label: const FuriganaText('全消し'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Step 3: 説明
          _StepCard(
            step: 3,
            title: 'この曲について教えて',
            color: const Color(0xFFE91E63),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FuriganaText(
                  'どんな気持ちで作った？\nどんな場面に合う曲？自由に書いてね！',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: '例: 春の公園で友達と遊ぶ楽しい曲にしました',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kMusicColor),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _saved ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: FuriganaText(
              _saved ? '✓ 保存済み！バッジ獲得！' : '💾 作品を保存する',
              style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}


class _StepCard extends StatelessWidget {
  final int step;
  final String title;
  final Color color;
  final Widget child;

  const _StepCard({required this.step, required this.title, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: Text('$step', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 10),
              FuriganaText(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
